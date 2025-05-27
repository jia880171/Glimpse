import 'package:flutter/material.dart';
import 'package:glimpse/trash_view.dart';

import 'create_glimpse.dart';
import 'rotatable_Glimpse_card_view.dart';
import 'date_picker_view.dart';
import 'glimpses_picker_view.dart';
import 'main.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (BuildContext context) => const MyHomePage(title: 'home?'),
    '/createGlimpse': (BuildContext context) => CreateGlimpse(),

    // filmViewer is used to view film in main
    // filmFinder is used as a dependent page to find film
    '/filmFinder': (BuildContext context) => const GlimpsesPickerView(),


    // prototype for test
    '/glimpsesPicker': (BuildContext context) => const GlimpsesPickerView(),

    '/trash': (BuildContext context) => TrashView(),
    // '/receipt': (BuildContext context) => RotatableGlimpseCardView(),
    '/datePicker': (BuildContext context) => DatePickerView(),
  };

  static getRoutes() {
    return routes;
  }
}
