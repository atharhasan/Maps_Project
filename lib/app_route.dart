import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/maps_cubit/maps_cubit.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/data/repository/maps_repository.dart';
import 'package:maps/data/web_services/place_web_services.dart';
import 'package:maps/presentation/screens/login_screen.dart';
import 'package:maps/presentation/screens/map_screen.dart';
import 'package:maps/presentation/screens/otp_screen.dart';

import 'constants/strings.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen :
        return MaterialPageRoute(builder: (_) =>
        BlocProvider<PhoneAuthCubit>.value(
          value: phoneAuthCubit!,
          child: LoginScreen(),
        ));

      case otpScreen :
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider<PhoneAuthCubit>.value(
              value: phoneAuthCubit!,
              child: OtpScreen(phoneNumber: phoneNumber,),
            ));

      case mapScreen :
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (BuildContext context) => MapsCubit(MapsRepository(PlaceWebServices())),
          child: const MapScreen(),
        ),
        );
    }

  }
}