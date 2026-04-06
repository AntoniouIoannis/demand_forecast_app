import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/page_header_with_navigation.dart';
import 'package:flutter/material.dart';
import 'products_model.dart';
export 'products_model.dart';

class ProductsWidget extends StatefulWidget {
  const ProductsWidget({super.key});

  static String routeName = 'Products';
  static String routePath = 'products';

  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  late ProductsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PageHeaderWithNavigation(
          title: 'Products',
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [],
          ),
        ),
      ),
    );
  }
}
