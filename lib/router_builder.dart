// ignore_for_file: avoid_print, unused_import

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

enum _BuilderType {
  basic(RoutePath.id),
  shell(RoutePathShell.id),
  statefulShell(RoutePathStatefulShell.id),
  statefulStackShell(RoutePathStatefulStackShell.id);

  final String name;

  const _BuilderType(this.name);

  static bool contains(String? name) {
    return _BuilderType.values.singleWhereOrNull(
          (e) => e.name == name,
        ) !=
        null;
  }

  static _BuilderType fromName(String name) {
    return _BuilderType.values.firstWhere((e) => e.name == name);
  }
}

enum _FunctionType {
  goRouterWidgetBuilder('GoRouterWidgetBuilder'),
  goRouterPageBuilder('GoRouterPageBuilder'),
  goRouterRedirect('GoRouterRedirect'),
  exitCallback('ExitCallback'),
  shellRouteBuilder('ShellRouteBuilder'),
  shellRoutePageBuilder('ShellRoutePageBuilder'),
  statefulShellRouteBuilder('StatefulShellRouteBuilder'),
  statefulShellRoutePageBuilder('StatefulShellRoutePageBuilder'),
  shellNavigationContainerBuilder('ShellNavigationContainerBuilder');

  final String name;

  const _FunctionType(this.name);
}

/// Main entrance of the builder, it will be used in build.yaml
Builder router(BuilderOptions options) {
  return PartBuilder(
    [GoRouterGenerator()],
    '.router.dart',
    header: '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
    ''',
    options: options,
    allowSyntaxErrors: true,
  );
}

class GoRouterGenerator extends GeneratorForAnnotation<GoRouterAnnotation> {
  final _willCheckFunctionType = <_FunctionType, List<String>>{};
  final _navigatorClass = 'NavigatorKey';
  final _navigatorKey = <String>{};

  GoRouterGenerator() {
    _FunctionType.values.forEach((type) => _willCheckFunctionType[type] = []);
  }

  // @override
  // FutureOr<String> generate(
  //   LibraryReader library,
  //   BuildStep buildStep,
  // ) async {
  //   print('router generate');
  //   return 'void main() {}';
  // }

  /// Looking for top-level variable that marked with GoRouterGenerator
  /// and generate corresponding routerConfig and route
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final goRouterGen = StringBuffer();
    final classGen = StringBuffer();
    final helperGen = StringBuffer();
    if (element is TopLevelVariableElement) {
      final value = element.computeConstantValue();
      final root = _getIterableValue(value);
      if (root != null) {
        final goRootName = _getStringArgumentFromAnnotation(annotation, 'routerConfigVariableName');
        goRouterGen.write('final $goRootName = <RouteBase>');
        _writeGoRoutes(root, goRouterGen, childrenSep: ';', isTopLevel: true);
        //
        final rootName = _getStringArgumentFromAnnotation(annotation, 'routeVariableName');
        final defRoot = 'root';
        _writeClassRoutes(classGen, childrenNodes: root, path: defRoot);
        _writeStringBufferAtTop(
            classGen, 'final $rootName = ${_classNameBasedOnPaths([defRoot])}();');
        //
        _writeHelper(helperGen);
      } else {
        //TODO error handling
      }
    } else {
      //TODO error handling
    }

    // print('<-- Router builder end.');

    //! Never return empty string, or it wouldn't create part file
    return helperGen.toString() +
        '\n//-----------------------------------------\n' +
        goRouterGen.toString() +
        '\n//-----------------------------------------\n' +
        classGen.toString() +
        '\n//-----------------------------------------\n';
  }

  String _getStringArgumentFromAnnotation(ConstantReader annotation, String argument) {
    return annotation.peek(argument)!.stringValue;
  }

  void _writeHelper(StringBuffer buffer) {
    // function type check
    buffer.write('void _typeCheck() {');
    _willCheckFunctionType.forEach((key, variableList) {
      if (variableList.isNotEmpty) {
        variableList.forEach((variable) {
          buffer.write('$variable is ${key.name};');
        });
        buffer.write('//-----------');
        buffer.write('\n');
      }
    });
    buffer.write('}');
    buffer.write('\n');
    // navigator key
    buffer.writeAll([
      'class $_navigatorClass {',
      ..._navigatorKey
          .map((e) => 'static final $e = GlobalKey<NavigatorState>(debugLabel: \'$e\');'),
      '}',
    ], '\n');
    // essential mixin
    buffer.writeAll([
      'mixin _ClassRouteMixin {',
      ' late Map<String, String?> _\$queryArgumentsMap = {};',
      ' String get _\$queryString => _\$queryArgumentsMap.entries.fold("", (prev, e) {',
      '   if (e.value != null) {',
      '     final pre = _\$queryArgumentsMap.entries.first.key == e.key ? "?" : "&";',
      '     return "\$prev\$pre\${e.key}=\${e.value}";',
      '   }',
      '   return prev;',
      ' },);',
      '}',
    ], '\n');
  }

  void _writeGoRoutes(
    List<DartObject>? children,
    StringBuffer buffer, {
    String childrenSep = ',',
    bool isTopLevel = false,
  }) {
    if (children == null) return;
    buffer.write('[');
    for (final element in children) {
      final buildType = element.type?.getDisplayString(withNullability: false);
      assert(
        _BuilderType.contains(buildType),
        '${_BuilderType.values.map((e) => e.name).join(' || ')} instance should be used.',
      );
      final type = _BuilderType.fromName(buildType!);
      switch (type) {
        case _BuilderType.basic:
          buffer.write('GoRoute(');
          _writeGeneralRouteInfo(element, buffer, isTopLevel);

          // add page builder
          final pageType = element.getField('pageType')?.toTypeValue();
          if (pageType != null) {
            final type = pageType.getDisplayString(withNullability: false);
            final pathArguments = _getSetValue(element.getField('pathArguments'));
            final arguments = _getSetValue(element.getField('arguments'));
            final extra = element.getField('extra')?.toBoolValue();
            buffer.writeAll([
              'builder: (context, state) {',
              '  return $type(',
              if (pathArguments != null)
                ...pathArguments.map((arg) {
                  final argName = arg.toStringValue();
                  return '$argName: state.pathParameters[\'$argName\']!,';
                }),
              if (arguments != null)
                ...arguments.map((arg) {
                  final argName = arg.toStringValue();
                  return '$argName: state.uri.queryParameters[\'$argName\']!,';
                }),
              if (extra == true) 'extra: state.extra,',
              '  );',
              '},',
            ], '\n');
          } else {
            _writeBuilderInfo(element, buffer, type);
          }
          buffer.write('),');
          break;

        case _BuilderType.shell:
          buffer.write('ShellRoute(');
          // add options
          _writeGeneralRouteInfo(element, buffer, isTopLevel);

          // add page builder
          var pageType = element.getField('pageType')?.toTypeValue();
          if (pageType != null) {
            final type = pageType.getDisplayString(withNullability: false);
            buffer.writeAll([
              'builder: (context, state, child) {',
              '  return $type();',
              '},',
            ], '\n');
          } else {
            _writeBuilderInfo(element, buffer, type);
          }

          buffer.write('),');
          break;
        case _BuilderType.statefulShell:
          buffer.write('StatefulShellRoute(');
          //
          final parentNavigatorKey = element.getField('parentNavigatorKey')?.toStringValue();
          if (parentNavigatorKey != null) {
            buffer.write('parentNavigatorKey: $_navigatorClass.$parentNavigatorKey,');
            _navigatorKey.add(parentNavigatorKey);
          }

          // add navigatorContainerBuilder
          final builder = element.getField('navigatorContainerBuilder')!.toFunctionValue()!;
          buffer.write('builder: ${builder.displayName},');
          _willCheckFunctionType[_FunctionType.shellNavigationContainerBuilder]!
              .add(builder.displayName);

          // add page builder
          var pageType = element.getField('pageType')?.toTypeValue();
          if (pageType != null) {
            final type = pageType.getDisplayString(withNullability: false);
            buffer.writeAll([
              'builder: (context, state, child) {',
              '  return $type();',
              '},',
            ], '\n');
          } else {
            _writeBuilderInfo(element, buffer, type);
          }
          // add branches
          final branches = _getIterableValue(element.getField('branches'));
          if (branches != null) {
            buffer.write('branches:');
            _writeStatefulShellBranches(branches, buffer);
          }

          buffer.write('),');
          break;
        case _BuilderType.statefulStackShell:
          buffer.write('StatefulShellRoute.indexedStack(');
          //
          final parentNavigatorKey = element.getField('parentNavigatorKey')?.toStringValue();
          if (parentNavigatorKey != null) {
            buffer.write('parentNavigatorKey: $_navigatorClass.$parentNavigatorKey,');
            _navigatorKey.add(parentNavigatorKey);
          }

          // add page builder
          var pageType = element.getField('pageType')?.toTypeValue();
          if (pageType != null) {
            final type = pageType.getDisplayString(withNullability: false);
            buffer.writeAll([
              'builder: (context, state, child) {',
              '  return $type();',
              '},',
            ], '\n');
          } else {
            _writeBuilderInfo(element, buffer, type);
          }
          // add branches
          final branches = _getIterableValue(element.getField('branches'));
          if (branches != null) {
            buffer.write('branches: <StatefulShellBranch>');
            _writeStatefulShellBranches(branches, buffer);
          }

          buffer.write('),');
          break;
      }
    }

    buffer.write(']$childrenSep');
  }

  void _writeStatefulShellBranches(
    List<DartObject>? children,
    StringBuffer buffer, {
    String childrenSep = ',',
    bool isTopLevel = false,
  }) {
    if (children == null) return;
    buffer.write('[');
    for (final element in children) {
      final buildType = element.type?.getDisplayString(withNullability: false);
      assert(
        buildType == 'RoutePathBranch',
        '[RoutePathBranch] instance should be used.',
      );
      buffer.write('StatefulShellBranch(');
      _writeGeneralRouteInfo(element, buffer, isTopLevel);
      // add initialLocation
      final initialLocation = element.getField('initialLocation')?.toStringValue();
      if (initialLocation != null) {
        buffer.write('initialLocation: $initialLocation,');
      }
      buffer.write('),');
    }

    buffer.write(']$childrenSep');
  }

  /// append:
  /// - path
  /// - redirect
  /// - parentNavigatorKey
  /// - name
  /// - [children]
  void _writeGeneralRouteInfo(DartObject element, StringBuffer buffer, bool isTopLevel) {
    var path = element.getField('path')?.toStringValue();
    if (path != null) {
      if (isTopLevel) path = '/' + path;
      final pathArguments = _getSetValue(element.getField('pathArguments'));
      // create path
      buffer.writeAll([
        'path: \'$path',
        if (pathArguments != null) ...pathArguments.map((arg) => '/:${arg.toStringValue()}'),
        '\',',
      ]);
    }
    // add options
    final redirect = element.getField('redirect')?.toFunctionValue();
    if (redirect != null) {
      final name = redirect.displayName;
      _willCheckFunctionType[_FunctionType.goRouterRedirect]!.add(name);
      buffer.write('redirect: $name,');
    }
    final onExit = element.getField('onExit')?.toFunctionValue();
    if (onExit != null) {
      final name = onExit.displayName;
      _willCheckFunctionType[_FunctionType.exitCallback]!.add(name);
      buffer.write('onExit: $onExit,');
    }
    final parentNavigatorKey = element.getField('parentNavigatorKey')?.toStringValue();
    if (parentNavigatorKey != null) {
      buffer.write('parentNavigatorKey: $_navigatorClass.$parentNavigatorKey,');
      _navigatorKey.add(parentNavigatorKey);
    }
    final navigatorKey = element.getField('navigatorKey')?.toStringValue();
    if (navigatorKey != null) {
      buffer.write('navigatorKey: $_navigatorClass.$navigatorKey,');
      _navigatorKey.add(navigatorKey);
    }
    final name = element.getField('name')?.toStringValue();
    if (name != null) {
      buffer.write('name: $name,');
    }
    // create children
    final childrenNodes = _getIterableValue(element.getField('routes'));
    if (childrenNodes != null) {
      buffer.write('routes:');
      _writeGoRoutes(childrenNodes, buffer);
    }
  }

  /// append
  /// - builder || pageBuilder
  void _writeBuilderInfo(DartObject element, StringBuffer buffer, _BuilderType type) {
    final builder = element.getField('builder')?.toFunctionValue();
    if (builder != null) {
      final name = builder.displayName;
      buffer.write('builder: $name,');
      //
      switch (type) {
        case _BuilderType.basic:
          _willCheckFunctionType[_FunctionType.goRouterWidgetBuilder]!.add(name);
          break;
        case _BuilderType.shell:
          _willCheckFunctionType[_FunctionType.shellRouteBuilder]!.add(name);
          break;
        case _BuilderType.statefulShell:
        case _BuilderType.statefulStackShell:
          _willCheckFunctionType[_FunctionType.statefulShellRouteBuilder]!.add(name);
          break;
      }
    }
    final pageBuilder = element.getField('pageBuilder')?.toFunctionValue();
    if (pageBuilder != null) {
      final name = pageBuilder.displayName;
      buffer.write('pageBuilder: $name,');
      //
      switch (type) {
        case _BuilderType.basic:
          _willCheckFunctionType[_FunctionType.goRouterPageBuilder]!.add(name);
          break;
        case _BuilderType.shell:
          _willCheckFunctionType[_FunctionType.shellRoutePageBuilder]!.add(name);
          break;
        case _BuilderType.statefulShell:
        case _BuilderType.statefulStackShell:
          _willCheckFunctionType[_FunctionType.statefulShellRoutePageBuilder]!.add(name);
          break;
      }
    }
  }

  void _writeClassRoutes(
    StringBuffer buffer, {
    List<DartObject>? childrenNodes,
    Set<DartObject>? pathArguments,
    Set<DartObject>? arguments,
    required String path,
    List<String> parentPath = const [],
  }) {
    final isRoot = parentPath.isEmpty;
    // flatten _shellBuilder first
    childrenNodes = childrenNodes?.fold<List<DartObject>>([], (prev, element) {
      final buildType = element.type?.getDisplayString(withNullability: false);
      final type = _BuilderType.fromName(buildType!);
      switch (type) {
        case _BuilderType.basic:
          return prev..add(element);
        case _BuilderType.shell:
          final routes = _getIterableValue(element.getField('routes'));
          if (routes != null) {
            return prev..addAll(routes);
          }
          return prev..add(element);
        case _BuilderType.statefulShell:
        case _BuilderType.statefulStackShell:
          final branches = _getIterableValue(element.getField('branches'));
          if (branches != null) {
            final routes = branches.fold(<DartObject>[], (prev, element) {
              // element is [RoutePathBranch] instance
              final routes = _getIterableValue(element.getField('routes'));
              if (routes != null) {
                return prev..addAll(routes);
              }
              return prev;
            });
            return prev..addAll(routes);
          }
          return prev..add(element);
        default:
          return prev;
      }
    });
    //TODO check duplicate paths
    //TODO [path] format check
    final className = _classNameBasedOnPaths([...parentPath, path]);
    final classBuffer = StringBuffer();
    classBuffer.write('class $className with _ClassRouteMixin {');
    final argumentBuffer = StringBuffer();
    // declare arguments
    argumentBuffer.writeAll([
      if (pathArguments.hasElement)
        ...pathArguments!.map((e) => 'final String ${_localVariable(e.toStringValue()!)};'),
      if (arguments.hasElement)
        ...arguments!.map((e) => 'final String? ${_localVariable(e.toStringValue()!)};'),
    ], '\n');
    // add query arguments map
    if (arguments.hasElement) {
      argumentBuffer.writeAll([
        '@override',
        'late Map<String, String?> _\$queryArgumentsMap = {',
        ...arguments!.map((e) => '"${e.toStringValue()!}": ${_localVariable(e.toStringValue()!)},'),
        '};',
      ], '\n');
    }
    // create init
    if (argumentBuffer.isNotEmpty) {
      argumentBuffer.writeAll([
        '$className(',
        if (!isRoot) ' this._\$parent,',
        _argumentsString(pathArguments: pathArguments, arguments: arguments),
        ') : ',
        _initArgumentsString(pathArguments: pathArguments, arguments: arguments),
        ';',
        '\n',
      ]);
    } else {
      argumentBuffer.writeAll([
        '$className(',
        if (!isRoot) ...[
          ' this._\$parent,',
        ],
        ');',
        '\n',
      ]);
    }
    classBuffer.write(argumentBuffer.toString());
    // add toString()
    final strElements = [
      if (!isRoot) path,
      ...(pathArguments ?? {}).map((e) => "\${${_localVariable(e.toStringValue()!)}}"),
    ];
    classBuffer.writeAll([
      if (!isRoot) '_ClassRouteMixin _\$parent;',
      '\n',
      '@override',
      'String toString() {',
      ' return ',
      if (!isRoot) '_\$parent.toString() + "/" +',
      '   "${strElements.join('/')}" + _\$queryString;',
      '}',
    ], '\n');
    //
    if (childrenNodes == null) {
      // leaf node
      classBuffer.write('}');
      _writeStringBufferAtTop(buffer, classBuffer.toString());
      return;
    }
    for (var child in childrenNodes) {
      final pathArguments = _getSetValue(child.getField('pathArguments'));
      final arguments = _getSetValue(child.getField('arguments'));
      final childPath = child.getField('path')?.toStringValue();
      if (childPath != null) {
        final childClassName = _classNameBasedOnPaths([...parentPath, path, childPath]);
        if (pathArguments.hasElement || arguments.hasElement) {
          classBuffer.writeAll([
            '$childClassName $childPath(${_argumentsString(pathArguments: pathArguments, arguments: arguments)}) {',
            ' return $childClassName(this, ${_inputArgumentsString(pathArguments: pathArguments, arguments: arguments)});',
            '}',
            '\n',
          ], '\n');
        } else {
          classBuffer.writeAll([
            '$childClassName get $childPath {',
            ' return $childClassName(this);',
            '}',
            '\n',
          ], '\n');
        }
        //
        final children = _getIterableValue(child.getField('routes'));
        _writeClassRoutes(
          buffer,
          childrenNodes: children,
          path: childPath,
          parentPath: [...parentPath, path],
          pathArguments: pathArguments,
          arguments: arguments,
        );
      }
    }
    classBuffer.write('}');
    buffer.write(classBuffer.toString());
  }

  List<DartObject>? _getIterableValue(DartObject? obj) => obj?.toListValue();

  Set<DartObject>? _getSetValue(DartObject? obj) => obj?.toSetValue();

  String _localVariable(String argument) => '__${argument}__';

  String _classNameBasedOnPaths(List<String> paths) => '_\$' + paths.join('\$');

  void _writeStringBufferAtTop(StringBuffer buffer, String str) {
    final old = buffer.toString();
    buffer.clear();
    buffer.writeAll([str, old], '\n');
  }

  String _initArgumentsString({Set<DartObject>? pathArguments, Set<DartObject>? arguments}) {
    final allArguments = {...pathArguments ?? {}, ...arguments ?? {}};
    return allArguments.isNotEmpty
        ? allArguments
            .map((e) => '${_localVariable(e.toStringValue()!)} = ${e.toStringValue()}')
            .join(',')
        : '';
  }

  String _argumentsString({Set<DartObject>? pathArguments, Set<DartObject>? arguments}) {
    return [
      '{',
      if (pathArguments.hasElement)
        ...pathArguments!.map((e) => 'required String ${e.toStringValue()},'),
      if (arguments.hasElement) ...arguments!.map((e) => 'String? ${e.toStringValue()},'),
      '}',
    ].join();
  }

  String _inputArgumentsString({Set<DartObject>? pathArguments, Set<DartObject>? arguments}) {
    final allArguments = {...pathArguments ?? {}, ...arguments ?? {}};
    return allArguments.isNotEmpty
        ? allArguments.map((e) => '${e.toStringValue()}: ${e.toStringValue()},').join()
        : '';
  }
}

extension on Set? {
  bool get hasElement => this?.isNotEmpty == true;
}
