/// An annotation which marking the top-level constant variable as a target of builder.
/// Usage:
/// @GoRouterAnnotation
/// const _whateverName = [
///   RouterPathBuilder(
///     'some_path_1',
///     routes: [...],
///   ),
///   RoutePathPageBuilder(
///     'some_path_2',
///     routes: [...],
///   )
/// ];
///
/// By default, two variables `router` and `route` will be created.
/// `router` is actually `routerConfig` that used as `MaterialApp.router`,
/// `route` is for generating location.
///
/// They can be changed by routerConfigVariableName and routeVariableName.
///
/// @GoRouterAnnotation(routerConfigVariableName: 'routerConfig', routeVariableName: 'myRoute')
/// const _whateverName = [...];
class GoRouterAnnotation {
  final String routerConfigVariableName;
  final String routeVariableName;
  const GoRouterAnnotation({
    this.routerConfigVariableName = 'router',
    this.routeVariableName = 'route',
  });
}

/// {@nodoc}
abstract class _RouteBuilder {
  const _RouteBuilder();
}

/// Corresponding to GoRoute in go_router in which using builder callback to create page elements.
/// In order to know which type of the target page, pageType is required.
/// Due to the limitation of code generation, only input top-level | constant | static arguments.
///
/// Usage:
/// const _path1 = RoutePath(
///   'some_path_1',
///   pageType: UserPage,
///   pathArguments: ['id'],
///   arguments: ['sort', 'type'],
/// );
class RoutePath extends _RouteBuilder {
  static const String id = 'RoutePath';

  final Type? pageType;
  final Function? builder;
  final Function? pageBuilder;

  final String? parentNavigatorKey;
  final String path;
  final String? name;
  final Set<String>? pathArguments;
  final Set<String>? arguments;
  final Function? redirect;
  final Function? onExit;
  final List<_RouteBuilder>? routes;
  final bool extra;

  /// Reflect to GoRoute class, using builder for building page of this route
  const RoutePath(
    this.path, {
    this.pageType,
    this.builder,
    this.pageBuilder,
    //
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
    this.extra = false,
  }) : assert(
          (pageType != null ? 1 : 0) + (builder != null ? 1 : 0) + (pageBuilder != null ? 1 : 0) ==
              1,
          'use either [pageType], [builder] or [pageBuilder].',
        );
}

/// Corresponding to ShellRoute in go_router
///
/// Usage:
/// final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
/// const _shellRoute = RoutePathShellBuilder(
///   navigatorKey: shellNavigatorKey,
///   routes: [
///     ...
///   ],
/// );
class RoutePathShell extends _RouteBuilder {
  static const String id = 'RoutePathShell';

  final Type? pageType;
  final Function? builder;
  final Function? pageBuilder;

  final dynamic parentNavigatorKey;
  final String? navigatorKey;
  final List<_RouteBuilder> routes;

  const RoutePathShell({
    required this.routes,
    this.pageType,
    this.builder,
    this.pageBuilder,
    //
    this.parentNavigatorKey,
    this.navigatorKey,
  }) : assert(
          (pageType != null ? 1 : 0) + (builder != null ? 1 : 0) + (pageBuilder != null ? 1 : 0) ==
              1,
          'use either [pageType], [builder] or [pageBuilder].',
        );
}

//------------------------
class RoutePathStatefulShell extends _RouteBuilder {
  static const String id = 'RoutePathStatefulShell';

  final Type? pageType;
  final Function? builder;
  final Function? pageBuilder;

  final List<RoutePathBranch> branches;
  final Function navigatorContainerBuilder;
  final String? parentNavigatorKey;

  const RoutePathStatefulShell({
    required this.branches,
    required this.navigatorContainerBuilder,
    this.pageType,
    this.builder,
    this.pageBuilder,
    //
    this.parentNavigatorKey,
  }) : assert(
          (pageType != null ? 1 : 0) + (builder != null ? 1 : 0) + (pageBuilder != null ? 1 : 0) ==
              1,
          'use either [pageType], [builder] or [pageBuilder].',
        );
}

class RoutePathStatefulStackShell extends _RouteBuilder {
  static const String id = 'RoutePathStatefulStackShell';

  final Type? pageType;
  final Function? builder;
  final Function? pageBuilder;

  final List<RoutePathBranch> branches;
  final String? parentNavigatorKey;

  const RoutePathStatefulStackShell({
    required this.branches,
    this.pageType,
    this.builder,
    this.pageBuilder,
    //
    this.parentNavigatorKey,
  }) : assert(
          (pageType != null ? 1 : 0) + (builder != null ? 1 : 0) + (pageBuilder != null ? 1 : 0) ==
              1,
          'use either [pageType], [builder] or [pageBuilder].',
        );
}

class RoutePathBranch extends _RouteBuilder {
  final String? navigatorKey;
  final String? initialLocation;
  final List<_RouteBuilder> routes;

  RoutePathBranch({
    this.navigatorKey,
    this.initialLocation,
    required this.routes,
  });
}
