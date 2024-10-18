import 'package:flutter/material.dart';

import 'create_glimpse.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    // '/': (BuildContext context) => const MyHomePage(title: 'home?'),
    '/createGlimpse': (BuildContext context) => CreateGlimpse(),
  };

  static getRoutes() {
    return routes;
  }
}
