import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_shippers/models/dto/create_dto/online_shipper_status_create_dto.dart';
import 'package:foodtogo_shippers/models/dto/login_request_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/online_shipper_status_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_shippers/models/enum/login_from_app.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/screens/current_accepted_order_screen.dart';
import 'package:foodtogo_shippers/screens/shipper_register_screen.dart';
import 'package:foodtogo_shippers/screens/tabs_screen.dart';
import 'package:foodtogo_shippers/screens/user_register_screen.dart';
import 'package:foodtogo_shippers/services/accepted_order_services.dart';
import 'package:foodtogo_shippers/services/online_shipper_status_services.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/shipper_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserServices _userServices = UserServices();

  late bool _isPasswordObscured;
  late bool _isLogining;
  bool _isLoginFailed = false;

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

  _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var loginRequestDTO = LoginRequestDTO(
        username: _usernameController.text,
        password: _passwordController.text,
        loginFromApp: LoginFromApp.Shipper.name,
      );

      if (mounted) {
        setState(() {
          _isLogining = true;
        });
      }

      final loginResponseDTO = await _userServices.login(loginRequestDTO);
      final userServices = UserServices();
      await userServices.getUserLocation();

      await userServices.checkLocalLoginAuthorized();
      if (UserServices.isAuthorized) {
        //update location to server
        await _updateLocation();

        //check if shipper is created?
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

        if (mounted) {
          setState(() {
            _isLogining = false;
          });
        }

        if (!loginResponseDTO.isSuccess) {
          //login failed
          setState(() {
            _isLoginFailed = true;
          });
        } else {
          setState(() {
            _isLoginFailed = false;
          });

          _routeByCurrentOrder(currentOrderId);
        }
      }
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

  @override
  void initState() {
    super.initState();
    _isPasswordObscured = true;
    _isLogining = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Shippers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 25, 40, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Log In',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your username.'),
                      ),
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      obscureText: _isPasswordObscured,
                      decoration: InputDecoration(
                        label: const Text('Enter your password.'),
                        suffixIcon: IconButton(
                          icon: _isPasswordObscured
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                      ),
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoginFailed)
                Text(
                  'Login Failed. Please check your username and password.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                child: _isLogining
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: KColors.kLightTextColor,
                      ),
                  children: [
                    const TextSpan(text: 'Click '),
                    TextSpan(
                      text: ' here ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const UserRegisterScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(text: ' to register.'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
