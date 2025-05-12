import 'package:flutter/material.dart';
import 'package:glimpse/trash_view.dart';

import 'create_glimpse.dart';
import 'date_picker_view.dart';
import 'film_roll_view.dart';
import 'main.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (BuildContext context) => const MyHomePage(title: 'home?'),
    '/createGlimpse': (BuildContext context) => CreateGlimpse(),

    '/filmRoll': (BuildContext context) => FilmRollView(),
    '/trash': (BuildContext context) => TrashView(),
    '/receipt'

    '/datePicker': (BuildContext context) => DatePickerView(),

  };

  static getRoutes() {
    return routes;
  }
}
