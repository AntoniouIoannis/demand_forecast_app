import '/flutter_flow/flutter_flow_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'tabimportdata_widget.dart' show TabimportdataWidget;
import 'package:flutter/material.dart';

class TabimportdataModel extends FlutterFlowModel<TabimportdataWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  // State field(s) for MainTabBarDEMAND widget.
  TabController? mainTabBarDEMANDController;
  int get mainTabBarDEMANDCurrentIndex => mainTabBarDEMANDController != null
      ? mainTabBarDEMANDController!.index
      : 0;
  int get mainTabBarDEMANDPreviousIndex => mainTabBarDEMANDController != null
      ? mainTabBarDEMANDController!.previousIndex
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    mainTabBarDEMANDController?.dispose();
  }
}
