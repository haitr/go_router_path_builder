import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_path_builder/annotation.dart';

part 'main.router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  String title = 'Flutter Demo Home Page';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String path = '';

  void _incrementCounter() {
    // setState(() {
    //   path = airoute.home.user(id: '123').detail.toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(path, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  final String id;
  final Object? extra;

  const UserPage({super.key, required this.id, this.extra});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  //
}

@GoRouterAnnotation(routeVariableName: 'airoute')
// ignore: unused_element
const _routes = [
  RoutePathStatefulStackShell(
    pageType: UserPage,
    branches: [
      RoutePathBranch(
        routes: [
          RoutePath(
            'home',
            pageType: UserPage,
          ),
        ],
      ),
      RoutePathBranch(
        routes: [
          RoutePath(
            'home1',
            pageType: UserPage,
            routes: [
              RoutePath(
                'home5',
                pageType: UserPage,
                routes: [
                  RoutePath(
                    'home6',
                    pageType: UserPage,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  RoutePath(
    'home2',
    pageType: UserPage,
    routes: [
      RoutePath(
        'home3',
        pageType: UserPage,
        routes: [
          RoutePath(
            'home4',
            pageType: UserPage,
          ),
        ],
      ),
    ],
  ),
];

FutureOr<String?> redirectHome(BuildContext context, GoRouterState state) {
  return null;
}
