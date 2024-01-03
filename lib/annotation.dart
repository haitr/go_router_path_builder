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
/// const _path1 = RoutePathBuilder(
///   'some_path_1',
///   pageType: UserPage,
///   pathArguments: ['id'],
///   arguments: ['sort', 'type'],
/// );
class RoutePath extends _RouteBuilder {
  static const String id = 'RoutePath';

  final Type pageType;

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
    required this.pageType,
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
    this.extra = false,
  });
}

/// Corresponding to GoRoute in go_router in which using pageBuilder callback to create page elements.
/// In order to build correctly, pageBuilder is required.
/// Due to the limitation of code generation, only input top-level | constant | static arguments.
///
/// Usage:
/// Page _userPageBuilder(BuildContext context, GoRouterState state) {
///   final id = state.pathParameters['id'];
///   final type = state.uri.queryParameters['type'];
///   return CustomTransitionPage(
///     key: state.pageKey,
///     child: UserPage(id: id, type: type),
///     transitionsBuilder: (context, animation, secondaryAnimation, child) {
///       return FadeTransition(
///         opacity = CurveTween(curve: Curves.easeInOutCirc).animate(animation),
///         child = child,
///       );
///     },
///   );
/// }
/// FutureOr<String?> _authRedirect(BuildContext context, GoRouterState state) {
///  return null;
/// }
/// const _path1 = RoutePathBuilder(
///   'some_path_1',
///   pageBuilder: _userPageBuilder,
///   pathArguments: ['id'],
///   arguments: ['sort', 'type'],
///   redirect: _authRedirect,
/// );
class RoutePathBuilder extends _RouteBuilder {
  static const String id = 'RoutePathBuilder';

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

  const RoutePathBuilder(
    this.path, {
    this.builder,
    this.pageBuilder,
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
  }) : assert(
          (builder != null) ^ (pageBuilder != null),
          'use either [builder] or [pageBuilder].',
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

  final Type pageType;

  final String? parentNavigatorKey;
  final String? navigatorKey;
  final List<_RouteBuilder>? routes;

  const RoutePathShell({
    required this.routes,
    required this.pageType,
    this.parentNavigatorKey,
    this.navigatorKey,
  });
}

class RoutePathShellBuilder extends _RouteBuilder {
  static const String id = 'RoutePathShellBuilder';

  final Function? builder;
  final Function? pageBuilder;

  final String? parentNavigatorKey;
  final String? navigatorKey;
  final List<_RouteBuilder>? routes;

  const RoutePathShellBuilder({
    required this.routes,
    this.parentNavigatorKey,
    this.navigatorKey,
    this.builder,
    this.pageBuilder,
  }) : assert(
          (builder != null) ^ (pageBuilder != null),
          'use either [builder] or [pageBuilder].',
        );
}
