import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/shipper_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/user_dto.dart';
import 'package:foodtogo_shippers/models/shipper.dart';
import 'package:foodtogo_shippers/screens/edit_shipper_screen.dart';
import 'package:foodtogo_shippers/screens/login_screen.dart';
import 'package:foodtogo_shippers/services/shipper_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class Me extends ConsumerStatefulWidget {
  const Me({Key? key}) : super(key: key);

  @override
  ConsumerState<Me> createState() => _MeState();
}

class _MeState extends ConsumerState<Me> {
  UserDTO? _currentUser;
  Shipper? _currentShipper;

  _loadCurrentUser() async {
    if (UserServices.userId == null) {
      log('_loadCurrentUser UserServices.userId == null');
      return;
    }
    final userServices = UserServices();
    int userId = UserServices.userId!;
    var userDTO = await userServices.getDTO(userId);

    if (userDTO == null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
      return;
    }

    setState(() {
      _currentUser = userDTO;
    });
  }

  _loadCurrentCustomer() async {
    if (UserServices.userId == null) {
      log('_loadCurrentCustomer UserServices.userId == null');
      return;
    }

    final shipperServices = ShipperServices();

    var shipper = await shipperServices.get(UserServices.userId!);

    if (shipper == null) {
      log('_loadCurrentCustomer shipper == null');
      throw Error();
    }

    if (mounted) {
      setState(() {
        _currentShipper = shipper;
      });
    }
  }

  _onTapChangeUserInfoPressed() async {
    if (_currentUser != null && _currentShipper != null) {
      List<Object>? results = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditShipperScreen(
            userDTO: _currentUser!,
            shipper: _currentShipper!,
          ),
        ),
      );

      if (results == null) {
        return;
      }

      if (results.length == 2) {
        final userUpdateDTO = results[0] as UserUpdateDTO;
        final shipperUpdateDTO = results[1] as ShipperUpdateDTO;

        setState(() {
          _currentUser = UserDTO(
            id: _currentUser!.id,
            username: _currentUser!.username,
            role: _currentUser!.role,
            phoneNumber: userUpdateDTO.phoneNumber,
            email: userUpdateDTO.email,
          );

          _currentShipper = Shipper(
            userId: _currentShipper!.userId,
            firstName: shipperUpdateDTO.firstName,
            lastName: shipperUpdateDTO.lastName,
            middleName: shipperUpdateDTO.middleName,
            vehicleNumberPlate: shipperUpdateDTO.vehicleNumberPlate,
            vehicleType: shipperUpdateDTO.vehicleType,
            phoneNumber: _currentShipper!.phoneNumber,
            email: _currentShipper!.email,
            rating: shipperUpdateDTO.rating,
            successOrderCount: _currentShipper!.successOrderCount,
            cancelledOrderCount: _currentShipper!.cancelledOrderCount,
          );
        });
      }
    }
  }

  _logout() {
    final userServices = UserServices();

    userServices.deleteStoredLoginInfo();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCurrentCustomer();
  }

  @override
  Widget build(BuildContext context) {
    Widget contain = const Center(
      child: CircularProgressIndicator(),
    );

    if (_currentUser != null && _currentShipper != null) {
      contain = Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
        width: double.infinity,
        color: KColors.kBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: KColors.kTextColor,
                        fontSize: 34,
                      ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: KColors.kLightTextColor,
                        ),
                    children: [
                      TextSpan(
                        text: _currentUser!.username,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: KColors.kPrimaryColor,
                              fontSize: 30,
                            ),
                      ),
                      TextSpan(
                        text: ' !',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: KColors.kTextColor,
                              fontSize: 34,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ListView(
                  children: [
                    Text(
                      'About you:',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: KColors.kLightTextColor,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: KColors.kOnBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.badge),
                            title: Text(
                                '${_currentShipper!.lastName} ${_currentShipper!.middleName} ${_currentShipper!.firstName}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(_currentUser!.phoneNumber),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text(_currentUser!.email),
                          ),
                          ListTile(
                            leading: const Icon(Icons.star),
                            title: Text(_currentShipper!.rating.toString()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Account:',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: KColors.kLightTextColor,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          if (_currentShipper != null && _currentUser != null)
                            Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10.0),
                              color: KColors.kOnBackgroundColor,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: KColors.kPrimaryColor,
                                ),
                                title: const Text('Change your account info'),
                                onTap: () {
                                  _onTapChangeUserInfoPressed();
                                },
                              ),
                            ),
                          const SizedBox(height: 10),
                          Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10.0),
                            child: ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: KColors.kPrimaryColor,
                              ),
                              title: const Text(
                                'Log out',
                                style: TextStyle(color: KColors.kPrimaryColor),
                              ),
                              onTap: _logout,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return contain;
  }
}
