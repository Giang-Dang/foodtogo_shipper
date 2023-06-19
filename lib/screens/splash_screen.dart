import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_shippers/models/dto/create_dto/online_shipper_status_create_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/online_shipper_status_update_dto.dart';
import 'package:foodtogo_shippers/screens/current_accepted_order_screen.dart';
import 'package:foodtogo_shippers/screens/login_screen.dart';
import 'package:foodtogo_shippers/screens/shipper_register_screen.dart';
import 'package:foodtogo_shippers/screens/tabs_screen.dart';
import 'package:foodtogo_shippers/services/accepted_order_services.dart';
import 'package:foodtogo_shippers/services/customer_services.dart';
import 'package:foodtogo_shippers/services/online_shipper_status_services.dart';
import 'package:foodtogo_shippers/services/shipper_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;
  Timer? _loginTimer;

  _updateLocation() async {
    final onlineShipperStatusSevices = OnlineShipperStatusServices();
    final getResult =
        await onlineShipperStatusSevices.getDTO(UserServices.userId!);

    if (getResult == null) {
      final onlineShipperStatusCreateDTO = OnlineShipperStatusCreateDTO(
        shipperId: UserServices.userId!,
        geoLatitude: UserServices.currentLatitude,
        geoLongitude: UserServices.currentLongitude,
        isAvailable: true,
      );
      final createResult =
          await onlineShipperStatusSevices.create(onlineShipperStatusCreateDTO);
    } else {
      final onlineShipperStatusUpdateDTO = OnlineShipperStatusUpdateDTO(
        shipperId: UserServices.userId!,
        geoLatitude: UserServices.currentLatitude,
        geoLongitude: UserServices.currentLongitude,
        isAvailable: getResult.isAvailable,
      );
      final updateResult = await onlineShipperStatusSevices.update(
          UserServices.userId!, onlineShipperStatusUpdateDTO);
    }
  }

  _routeByCurrentOrder(int currentOrderId) {
    if (currentOrderId == 0) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                CurrentAcceptedOrderScreen(orderId: currentOrderId),
          ),
        );
      }
    }
  }

  _login() async {
    //delay for animation
    // await _delay(100);
    //loading data
    final userServices = UserServices();

    await userServices.getUserLocation();

    await userServices.checkLocalLoginAuthorized();
    if (UserServices.isAuthorized) {
      //update location to server
      await _updateLocation();

      final shipperServices = ShipperServices();
      final shipperQueryResult =
          await shipperServices.getDTO(UserServices.userId!);

      if (shipperQueryResult == null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShipperRegisterScreen(userId: UserServices.userId!),
            ),
          );
        }
        return;
      }

      //check if shipper is currently delivering an order
      final acceptedOrderServices = AcceptedOrderServices();

      final currentOrderId =
          await acceptedOrderServices.getCurrentOrderId(UserServices.userId!);
      UserServices.currentOrderId = currentOrderId;

      //route
      _routeByCurrentOrder(currentOrderId);
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  _delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  @override
  void initState() {
    super.initState();
    //animation
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _textAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_textAnimationController);

    //login
    _loginTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        _login();
        _loginTimer?.cancel();
      },
    );
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _loginTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 35,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'We are getting your location. Please wait.',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/getting_location.gif',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 15),
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                if (_textAnimation.value < 0.25) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.25 &&
                    _textAnimation.value < 0.5) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.5 &&
                    _textAnimation.value < 0.75) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading..',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 90)
          ],
        ),
      ),
    );
  }
}
