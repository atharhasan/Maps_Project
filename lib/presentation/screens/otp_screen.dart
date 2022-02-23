import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/app_colors.dart';
import 'package:maps/constants/strings.dart';
import 'package:maps/presentation/widgets/show_progress_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
     OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);
   final phoneNumber ;
   late String otpCode;

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const Text("Verify your phone number",style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold),),
        const SizedBox(height: 30,),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
          text: TextSpan(
            text: 'Enter your 6 digit code numbers sent to ',
            style: const TextStyle(color: Colors.black, fontSize: 18, height: 1.4),
            children: [
              TextSpan(text: '$phoneNumber',
                style: const TextStyle(color: AppColors.blue),
              ),
            ]
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        autoFocus: true,
        cursorColor: AppColors.blue,
        keyboardType: TextInputType.number,
        obscureText: false,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          borderWidth: 1,
          activeColor: AppColors.blue,
          inactiveColor: AppColors.blue,
          activeFillColor: AppColors.lightBlue,
          inactiveFillColor: Colors.white,
          selectedColor: AppColors.blue,
          selectedFillColor: Colors.white
        ),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        onCompleted: (submittedCode) {
          otpCode = submittedCode;
          print("Completed");
        },
        onChanged: (value) {
          print(value);
          },
          ),);
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _login(context);
        },
        child: const Text('Verify', style: TextStyle(fontSize: 16,color: Colors.white),),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(110, 50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void _login(BuildContext context){
    BlocProvider.of<PhoneAuthCubit>(context).submitOTP(otpCode);
  }

    Widget _buildPhoneVerificationBloc () {
    return BlocListener<PhoneAuthCubit,PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state){
        if ( state is Loading) {
          showProgressIndicator(context);
        }
        if (state is PhoneOTPVerified) {
          Navigator.pop(context);
          Navigator.of(context).pushReplacementNamed(mapScreen);
        }

        if( state is ErrorOccurred) {
          Navigator.pop(context);
          String errorMsg = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 5),
          ));
        }
      },
      child: Container(),
    );
    }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 65),
            child: Column(
              children: [
                _buildIntroText(),
                const SizedBox(height: 88,),
                _buildPinCodeField(context),
                const SizedBox(height: 50,),
                _buildVerifyButton(context),
                _buildPhoneVerificationBloc(),
              ],
            ),
          ),
        ));
  }
}
