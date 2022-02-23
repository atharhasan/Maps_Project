import 'package:flutter/material.dart';
import 'package:maps/constants/app_colors.dart';

void showProgressIndicator (BuildContext context) {
  AlertDialog alertDialog = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
      ),
    ),
  );
  showDialog(
    barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      context: context,
      builder: (context){
    return alertDialog;
      }
  );
}
