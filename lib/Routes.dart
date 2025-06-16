import 'package:flutter/material.dart';
import 'package:glimpse/widgets/trash.dart';

import 'create_glimpse.dart';
import 'widgets/rotatable_card/rotatable_Glimpse_card_view.dart';
import 'film_finder_view.dart';
import 'main.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (BuildContext context) => const MyHomePage(title: 'home?'),
    '/createGlimpse': (BuildContext context) => CreateGlimpse(),

    // filmViewer is used to view film in main
    // filmFinder is used as a dependent page to find film
    '/filmFinder': (BuildContext context) => const FilmFinderView(),


    // prototype for test
    '/glimpsesPicker': (BuildContext context) => const FilmFinderView(),

    // '/trash': (BuildContext context) => TrashView(widgetSize: null,),
    // '/receipt': (BuildContext context) => RotatableGlimpseCardView(),
    // '/datePicker': (BuildContext context) => DatePickerView(),
  };

  static getRoutes() {
    return routes;
  }
}
