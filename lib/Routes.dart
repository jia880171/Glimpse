import 'package:flutter/material.dart';

import 'CreateGlimpse.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    // '/': (BuildContext context) => const MyHomePage(title: 'home?'),
    '/createGlimpse': (BuildContext context) => CreateGlimpse(),
  };

  static getRoutes() {
    return routes;
  }
}
