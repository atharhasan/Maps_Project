part of 'phone_auth_cubit.dart';

@immutable
abstract class PhoneAuthState {}

class PhoneAuthInitial extends PhoneAuthState {}

class Loading extends PhoneAuthState {}

class ErrorOccurred extends PhoneAuthState {
  final String errorMsg;

  ErrorOccurred(this.errorMsg);
}

class PhoneNumberSubmitted extends PhoneAuthState {}

class PhoneOTPVerified extends PhoneAuthState {}
