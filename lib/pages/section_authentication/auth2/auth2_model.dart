import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'auth2_widget.dart' show Auth2Widget;
import 'package:flutter/material.dart';

class Auth2Model extends FlutterFlowModel<Auth2Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBarDuo widget.
  TabController? tabBarDuoController;
  int get tabBarDuoCurrentIndex =>
      tabBarDuoController != null ? tabBarDuoController!.index : 0;
  int get tabBarDuoPreviousIndex =>
      tabBarDuoController != null ? tabBarDuoController!.previousIndex : 0;

  // State field(s) for txtFieldEmailCreate widget.
  FocusNode? txtFieldEmailCreateFocusNode;
  TextEditingController? txtFieldEmailCreateTextController;
  String? Function(BuildContext, String?)?
      txtFieldEmailCreateTextControllerValidator;
  // State field(s) for password_Create widget.
  FocusNode? passwordCreateFocusNode;
  TextEditingController? passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(BuildContext, String?)?
      passwordCreateTextControllerValidator;
  // State field(s) for repassword_Create widget.
  FocusNode? repasswordCreateFocusNode;
  TextEditingController? repasswordCreateTextController;
  late bool repasswordCreateVisibility;
  String? Function(BuildContext, String?)?
      repasswordCreateTextControllerValidator;
  // State field(s) for txtFieldMobilehpone widget.
  FocusNode? txtFieldMobilehponeFocusNode;
  TextEditingController? txtFieldMobilehponeTextController;
  String? Function(BuildContext, String?)?
      txtFieldMobilehponeTextControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordCreateVisibility = false;
    repasswordCreateVisibility = false;
    passwordVisibility = false;
  }

  @override
  void dispose() {
    tabBarDuoController?.dispose();
    txtFieldEmailCreateFocusNode?.dispose();
    txtFieldEmailCreateTextController?.dispose();

    passwordCreateFocusNode?.dispose();
    passwordCreateTextController?.dispose();

    repasswordCreateFocusNode?.dispose();
    repasswordCreateTextController?.dispose();

    txtFieldMobilehponeFocusNode?.dispose();
    txtFieldMobilehponeTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
