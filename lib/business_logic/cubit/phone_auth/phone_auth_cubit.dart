
import 'dart:async';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  late String verificationId;

  PhoneAuthCubit() : super(PhoneAuthInitial());

  Future <void> submittedPhoneNumber(String phoneNumber) async {
    emit(Loading());

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+2$phoneNumber',
      timeout: const Duration(seconds: 20),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    await signIn(credential);
    print('verificationCompleted');
  }

  void verificationFailed(FirebaseAuthException error) {
    emit(ErrorOccurred(error.toString()));
    print('verificationFailed : ${error.toString()}');
  }

  void codeSent(String verificationId, int? resendToken) {
    print('code sent');
    this.verificationId = verificationId;
    emit(PhoneNumberSubmitted());
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
  }


  Future <void> submitOTP(String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential
      (verificationId: verificationId, smsCode: otpCode);

    await signIn(credential);
  }

  Future <void> signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneOTPVerified());
    } catch (error) {
      emit(ErrorOccurred(error.toString()));
    }
  }

  Future <void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  User getLoggedInUser() {
    User currentUser = FirebaseAuth.instance.currentUser!;
    return currentUser;
  }
}
