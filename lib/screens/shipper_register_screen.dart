import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/dto/create_dto/shipper_create_dto.dart';
import 'package:foodtogo_shippers/screens/tabs_screen.dart';
import 'package:foodtogo_shippers/services/shipper_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class ShipperRegisterScreen extends StatefulWidget {
  const ShipperRegisterScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final int userId;

  @override
  State<ShipperRegisterScreen> createState() => _ShipperRegisterScreenState();
}

class _ShipperRegisterScreenState extends State<ShipperRegisterScreen> {
  final _formCustomerRegisterKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberPlateController = TextEditingController();

  final _userServices = UserServices();

  bool _isRegistering = false;

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                onOkPressed();
              },
            ),
          ],
        );
      },
    );
  }

  _onRegisterPressed() async {
    if (widget.userId == 0) {
      log('_onRegisterPressed widget.userId == 0');
      return;
    }

    if (_formCustomerRegisterKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isRegistering = true;
        });
      }
    }

    final shipperServices = ShipperServices();
    final shipperCreateDTO = ShipperCreateDTO(
      userId: widget.userId,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      middleName: _middleNameController.text,
      vehicleNumberPlate: _vehicleNumberPlateController.text,
      vehicleType: _vehicleTypeController.text,
    );

    final shipperId = await shipperServices.create(shipperCreateDTO);

    if (shipperId == 0) {
      _showAlertDialog(
        'Sorry',
        'Unable to create your account at the moment. Please try again at a later time.',
        () {
          Navigator.of(context).pop();
        },
      );
      return;
    }

    _showAlertDialog(
      'Success',
      'Yay! Your account has been created successfully. Let\'s get started and find an order for you to deliver.',
      () {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const TabsScreen(),
        ));
      },
    );
  }

  bool _isValidVietnamesePlate(String plate) {
    final pattern = RegExp(r'^\d{2}-[A-Z]\d\s?\d{3,4}(\.\d{2})?$');
    return pattern.hasMatch(plate);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Customers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formCustomerRegisterKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shipper Register',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your first name'),
                      ),
                      controller: _firstNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid first name.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                    color: KColors.kOnBackgroundColor,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your middle name'),
                      ),
                      controller: _middleNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid middle name.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                    color: KColors.kOnBackgroundColor,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your last name'),
                      ),
                      controller: _lastNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid last name.';
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
                    Icons.two_wheeler,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your new vehicle type'),
                      ),
                      controller: _vehicleTypeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid vehicle type.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
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
                    Icons.pin_outlined,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your new vehicle number plate'),
                      ),
                      controller: _vehicleNumberPlateController,
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter a valid vehicle number plate.';
                        }
                        if (_isValidVietnamesePlate(value)) {
                          return null;
                        }
                        return 'Please enter a valid vehicle number plate.';
                      },
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _onRegisterPressed();
                  },
                  child: _isRegistering
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
