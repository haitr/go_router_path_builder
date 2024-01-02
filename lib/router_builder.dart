// ignore_for_file: avoid_print, unused_import

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

const _builder = 'RoutePathBuilder';
const _pageBuilder = 'RoutePathPageBuilder';
const _shellBuilder = 'RoutePathShellBuilder';

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
    // print('Router builder start -->');
    // final pageType = _getStringArgumentFromAnnotation(annotation, 'pageType');
    if (element is TopLevelVariableElement) {
      final value = element.computeConstantValue();
      final root = _getIterableValue(value);
      if (root != null) {
        //
        helperGen.writeAll([
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
        //
        final goRootName = _getStringArgumentFromAnnotation(annotation, 'routerConfigVariableName');
        goRouterGen.write('final $goRootName = <RouteBase>');
        _writeGoRoutes(root, goRouterGen, childrenSep: ';', isTopLevel: true);
        //
        final rootName = _getStringArgumentFromAnnotation(annotation, 'routeVariableName');
        final defRoot = 'root';
        _writeClassRoutes(classGen, childrenNodes: root, path: defRoot);
        _writeStringBufferAtTop(
            classGen, 'final $rootName = ${_classNameBasedOnPaths([defRoot])}();');
      } else {
        //TODO error handling
      }
    } else {
      //TODO error handling
    }

    // print('<-- Router builder end.');

    //! Never return empty string, or it wouldn't create part file
    return goRouterGen.toString() +
        '\n//-----------------------------------------\n' +
        classGen.toString() +
        '\n//-----------------------------------------\n' +
        helperGen.toString();
  }

  String _getStringArgumentFromAnnotation(ConstantReader annotation, String argument) {
    return annotation.peek(argument)!.stringValue;
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
        [_builder, _pageBuilder, _shellBuilder].contains(buildType),
        '$_builder, $_pageBuilder or $_shellBuilder class should be use as element.',
      );
      if (buildType == _builder) {
        buffer.write('GoRoute(');
        _writeGeneralRouteInfo(element, buffer, isTopLevel);
        // create builder
        //TODO type check
        final pathArguments = _getSetValue(element.getField('pathArguments'));
        final pageClassType = element.getField('pageClassType')?.toTypeValue();
        if (pageClassType != null) {
          final type = pageClassType.getDisplayString(withNullability: false);
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
        }
        buffer.write('),');
      }
      if (buildType == _pageBuilder) {
        buffer.write('GoRoute(');
        _writeGeneralRouteInfo(element, buffer, isTopLevel);
        // create builder
        final pageBuilder = element.getField('pageBuilder')?.toFunctionValue();
        if (pageBuilder != null) {
          buffer.write('pageBuilder: ${pageBuilder.displayName},');
        }
        buffer.write('),');
      }
      if (buildType == _shellBuilder) {
        buffer.write('ShellRoute(');
        // add options
        var pageClassType = element.getField('pageClassType')?.toTypeValue();
        var builder = element.getField('builder')?.toFunctionValue();
        var pageBuilder = element.getField('pageBuilder')?.toFunctionValue();
        assert(
          pageClassType != null || ((pageBuilder != null) ^ (builder != null)),
          'Either [pageClassType || pageBuilder || builder] should be used.',
        );
        var parentNavigatorKey = element.getField('parentNavigatorKey')?.toStringValue();
        if (parentNavigatorKey != null) {
          buffer.write('parentNavigatorKey: $parentNavigatorKey,');
        }
        var navigatorKey = element.getField('navigatorKey')?.toStringValue();
        if (parentNavigatorKey != null) {
          buffer.write('navigatorKey: $navigatorKey,');
        }
        // create children
        var childrenNodes = _getIterableValue(element.getField('routes'));
        if (childrenNodes != null) {
          buffer.write('routes:');
          _writeGoRoutes(childrenNodes, buffer);
        }
        buffer.write('),');
      }
    }

    buffer.write(']$childrenSep');
  }

  void _writeGeneralRouteInfo(DartObject element, StringBuffer buffer, bool isTopLevel) {
    var path = element.getField('path')!.toStringValue()!;
    if (isTopLevel) path = '/' + path;
    final pathArguments = _getSetValue(element.getField('pathArguments'));
    // create path
    buffer.writeAll([
      'path: \'$path',
      if (pathArguments != null) ...pathArguments.map((arg) => '/:${arg.toStringValue()}'),
      '\',',
    ]);
    // add options
    final redirect = element.getField('redirect')?.toFunctionValue();
    if (redirect != null) {
      //TODO function arguments check
      buffer.write('redirect: ${redirect.displayName},');
    }
    final parentNavigatorKey = element.getField('parentKey')?.toStringValue();
    if (parentNavigatorKey != null) {
      buffer.write('parentNavigatorKey: $parentNavigatorKey,');
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
      if (buildType != null) {
        if (buildType == _builder || buildType == _pageBuilder) {
          return prev..add(element);
        }
        if (buildType == _shellBuilder) {
          final children = _getIterableValue(element.getField('routes'));
          if (children != null) {
            return prev..addAll(children);
          }
          return prev..add(element);
        }
      }
      return prev;
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
