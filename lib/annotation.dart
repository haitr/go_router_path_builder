class GoRouterAnnotation {
  final String goRootVariableName;
  final String rootVariableName;
  const GoRouterAnnotation({
    this.goRootVariableName = 'router',
    this.rootVariableName = 'route',
  });
}

abstract class _RouteBuilder {
  const _RouteBuilder();
}

class RoutePathBuilder extends _RouteBuilder {
  final String? parentNavigatorKey;
  final String path;
  final String? name;
  final Set<String>? pathArguments;
  final Set<String>? arguments;
  final Function? redirect;
  final Function? onExit;
  final Type? pageClassType;
  final List<_RouteBuilder>? routes;
  final bool extra;

  /// Reflect to GoRoute class, using builder for building page of this route
  const RoutePathBuilder(
    this.path, {
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
    this.pageClassType,
    this.extra = false,
  });
}

class RoutePathPageBuilder extends _RouteBuilder {
  final String? parentNavigatorKey;
  final String path;
  final String? name;
  final Set<String>? pathArguments;
  final Set<String>? arguments;
  final Function? redirect;
  final Function? onExit;
  final Function? pageBuilder;
  final List<_RouteBuilder>? routes;

  const RoutePathPageBuilder(
    this.path, {
    this.name,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.pathArguments,
    this.arguments,
    this.routes,
    this.pageBuilder,
  });
}

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
