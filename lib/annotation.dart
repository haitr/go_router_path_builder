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
/// In order to know which type of the target page, pageClassType is required.
/// Due to the limitation of code generation, only input top-level | constant | static arguments.
///
/// Usage:
/// const _path1 = RoutePathBuilder(
///   'some_path_1',
///   pageClassType: UserPage,
///   pathArguments: ['id'],
///   arguments: ['sort', 'type'],
/// );
class RoutePathBuilder extends _RouteBuilder {
  final String? parentNavigatorKey;
  final String path;
  final String? name;
  final Set<String>? pathArguments;
  final Set<String>? arguments;
  final Function? redirect;
  final Function? onExit;
  final Type pageClassType;
  final List<_RouteBuilder>? routes;
  final bool extra;

  /// Reflect to GoRoute class, using builder for building page of this route
  const RoutePathBuilder(
    this.path, {
    required this.pageClassType,
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
class RoutePathPageBuilder extends _RouteBuilder {
  final String? parentNavigatorKey;
  final String path;
  final String? name;
  final Set<String>? pathArguments;
  final Set<String>? arguments;
  final Function? redirect;
  final Function? onExit;
  final Function pageBuilder;
  final List<_RouteBuilder>? routes;

  const RoutePathPageBuilder(
    this.path, {
    required this.pageBuilder,
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
  });
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
class RoutePathShellBuilder extends _RouteBuilder {
  final String? navigatorKey;
  //
  final Type? pageClassType;
  final String? customPageBuilder;
  final List<_RouteBuilder>? routes;
  final String? parentNavigatorKey;

  const RoutePathShellBuilder({
    required this.routes,
    this.parentNavigatorKey,
    this.navigatorKey,
    this.pageClassType,
    this.customPageBuilder,
  });
}
