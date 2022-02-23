import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/app_colors.dart';
import 'package:maps/constants/strings.dart';
import 'package:maps/presentation/widgets/show_progress_indicator.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> _phoneFormKey = GlobalKey();
  late String phoneNumber ;

  //to build the text in the top of page
  Widget _buildTextWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const Text("What is your phone number ?",style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold),),
        const SizedBox(height: 30,),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: const Text("Please enter your phone number to verify your account",
            style: TextStyle(fontSize: 18,),),
        ),
      ],
    );
  }
  Widget _buildPhoneFormField() {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration:BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: const BorderRadius.all(Radius.circular(6))),
              child: Text(generateCountryFlag() + ' +20' , style: const TextStyle(fontSize: 18, letterSpacing: 2.0),),
            )
        ),
        const SizedBox(width: 16,),
        _phoneFormField()
      ],
    );
  }

  //method to generate country flag symbol.
  String generateCountryFlag() {
    String countryCode = 'eg';
    String flag = countryCode.toUpperCase().
    replaceAllMapped(RegExp(r'[A-Z]'), (match) =>
        String.fromCharCode(match.group(0)!.codeUnitAt(0)+ 127397));
    return flag;
  }

  Widget _phoneFormField() {
    return Expanded(
        flex: 2,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration:BoxDecoration(
              border: Border.all(color: AppColors.blue),
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: TextFormField(
            autofocus: true,
            style: const TextStyle(fontSize: 18,),
            decoration: const InputDecoration(border: InputBorder.none),
            cursorColor: AppColors.blue,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if(value!.isEmpty){
                return 'Please enter your phone number!';
              } else if (value.length < 11) {
                return 'Too short for a phone number!';
              }
              return null;
            },
            onSaved: (value) {
              phoneNumber = value!;
            },
          ),
        )
    );
  }

  // to build next button .
  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
          onPressed: () {
            showProgressIndicator(context);

            _register(context);
          },
          child: const Text('Next', style: TextStyle(fontSize: 16,color: Colors.white),),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(110, 50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    if (!_phoneFormKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    }else {
      Navigator.pop(context);
      _phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submittedPhoneNumber(phoneNumber);
    }
  }

  // to build bloc and stats that control app process.
  Widget _buildPhoneNumberSubmittedBloc() {
    // final String phoneNumber;
    return BlocListener<PhoneAuthCubit,PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state){
        if ( state is Loading) {
          showProgressIndicator(context);
        }
        if (state is PhoneNumberSubmitted) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpScreen,arguments: phoneNumber);
        }

        if( state is ErrorOccurred) {
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
          body: Form(
            key: _phoneFormKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 65),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTextWidget(),
                  const SizedBox(height: 110,),
                  _buildPhoneFormField(),
                  const Expanded(child: SizedBox(height: 60,)),
                  _buildNextButton(context),
                  _buildPhoneNumberSubmittedBloc(),

                ],
              ),
            ),
          ),
        ));
  }
}
