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
    '/glimpsesPicker': (BuildContext context) => const GlimpsesPickerView(),
    '/trash': (BuildContext context) => TrashView(),
    // '/receipt': (BuildContext context) => RotatableGlimpseCardView(),
    '/datePicker': (BuildContext context) => DatePickerView(),
  };

  static getRoutes() {
    return routes;
  }
}
