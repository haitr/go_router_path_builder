// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

Widget aaa(BuildContext, GoRouterState, StatefulNavigationShell) {
  throw '';
}

class NavigatorKey {
  static final aaa = GlobalKey<NavigatorState>();
}

final router = <RouteBase>[
  StatefulShellRoute.indexedStack(
    builder: (context, state, child) {
      return UserPage();
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) {
              return UserPage();
            },
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/home1',
    builder: (context, state) {
      return UserPage();
    },
  ),
];
//-----------------------------------------
final airoute = _$root();

class _$root$home1 with _ClassRouteMixin {
  _$root$home1(
    this._$parent,
  );
  _ClassRouteMixin _$parent;

  @override
  String toString() {
    return _$parent.toString() + "/" + "home1" + _$queryString;
  }
}

class _$root$home with _ClassRouteMixin {
  _$root$home(
    this._$parent,
  );
  _ClassRouteMixin _$parent;

  @override
  String toString() {
    return _$parent.toString() + "/" + "home" + _$queryString;
  }
}

class _$root with _ClassRouteMixin {
  _$root();

  @override
  String toString() {
    return "" + _$queryString;
  }

  _$root$home get home {
    return _$root$home(this);
  }

  _$root$home1 get home1 {
    return _$root$home1(this);
  }
}

//-----------------------------------------
mixin _ClassRouteMixin {
  late Map<String, String?> _$queryArgumentsMap = {};
  String get _$queryString => _$queryArgumentsMap.entries.fold(
        "",
        (prev, e) {
          if (e.value != null) {
            final pre = _$queryArgumentsMap.entries.first.key == e.key ? "?" : "&";
            return "$prev$pre${e.key}=${e.value}";
          }
          return prev;
        },
      );
}
