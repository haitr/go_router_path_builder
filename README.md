# go_router_path_builder

A flutter package to generate go_router path in functional style.

## Getting Started

### Overview

Obviously Flutter Team has already created a great library `go_router_builder` for explicit route definition. However the implementing steps are complicated for me, this package provided another approach.
The idea behind is very simple: instead of using `String` to navigate to a location:

```dart
context.go('/home/user/123/detail');
```

use builder to create navigating location with a help of code auto completion in order to avoid typos:

```dart
context.go(router.home.user(id: '123').detail.toString());
```

### Source code

Here is an instruction for using this builder. Importing `go_router.dart` is necessary (sure, we are using `go_router`) and including a `part` that references to the generated file. The generated file will always have a name `[source_file].router.dart`.

```dart
import 'package:go_router/go_router.dart';
import 'package:go_router_path_builder/go_router_path_builder.dart';

part 'this_file.router.dart';
```

Then, let's create top-level array containing `RoutePathBuilder`, `RoutePathPageBuilder` or `RoutePathShellBuilder` instance. Don't forget to mark it with `GoRouterAnnotation` annotation.

Example:
```dart
@GoRouterAnnotation()
const _routes = [
  RoutePathBuilder(
    'home',
    pageClassType: UserPage,
    routes: [
      RoutePathBuilder(
        'user',
        pathArguments: {'id'},
        pageClassType: UserPage,
        routes: [
          RoutePathBuilder('detail', pageClassType: UserDetailPage),
        ],
        extra: true,
      ),
    ],
    redirect: redirectHome,
  ),
];
```

After built, two variables `router` and `route` will be created. `router` is actually `routerConfig` that used as `MaterialApp.router` and `route` is for generating location. You can set those variable names in `@GoRouterAnnotation` arguments.
```dart
MaterialApp.router(
    //...
    routerConfig: router,
    //...
);
```
Usage:
```dart
// Generate /home/user/123/detail
final String location = route.home.user(id: '123').detail.toString();
```
If `RoutePathBuilder` or `RoutePathPageBuilder` has no argument, the corresponding location in `route` must be treated as a property.
```dart
// Generate /home
final String location = route.home.toString();
```
If they have some arguments, now that location became function style. Just put values on them. 
```dart
// Generate /home/user/123
final String location = route.home.user(id: '123').toString();
```

#### `RoutePathBuilder` and `RoutePathPageBuilder`
By using `RoutePathBuilder`, `GoRoute` instance will be generated with `builder` as page builder.
`pageClassType` is required, it is the class name of the page.

By using `RoutePathPageBuilder`, `GoRoute` instance will be generated with `pageBuilder` as page builder.
`pageBuilder` is required, it is the `pageBuilder` function of `GoRoute`.

`pathArguments` and `arguments` are optional `Set<String>?`. Set them values in order to add parameters into the location.
`pathArguments` is `pathParameters` and `arguments` is `uri.queryParaments` in `GoRouterState`.

Set `extra` to `true` if extra object will be used.

#### `RoutePathShellBuilder`
By using this, `ShellRoute` instance will be generated.

The function type arguments, like `pageBuilder`, `onExit`, `redirect` will be reflected directly into `GoRoute`. Only static or top-level variables available due to the limitation of code generation. Please look at `redirectHome` in [example](example/lib/main.dart).

### Run `build_runner`

To do a one-time build:

```console
dart run build_runner build
```

Or, to watch the changes while developing


```console
dart run build_runner watch
```

Just watching a specific file for faster code-gen
```console
dart run build_runner watch --build-filter 'lib/main.dart'
```

Read more about using
[`build_runner` on pub.dev](https://pub.dev/packages/build_runner).

### Dependencies

To use `go_router_path_builder`, please add the following dependences into `pubspec.yaml`.

```yaml
dependencies:
  # ...
  go_router: any

dev_dependencies:
  # ...
  build_runner: any
  go_router_path_builder: ^0.0.1
```

### TODO

- <input type="checkbox" disabled /> Add test cases
- <input type="checkbox" disabled /> Support StatefulShellRoute