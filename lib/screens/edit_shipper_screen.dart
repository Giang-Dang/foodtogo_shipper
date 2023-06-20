import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/customer_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/shipper_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/user_dto.dart';
import 'package:foodtogo_shippers/models/shipper.dart';
import 'package:foodtogo_shippers/services/customer_services.dart';
import 'package:foodtogo_shippers/services/shipper_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class EditShipperScreen extends StatefulWidget {
  const EditShipperScreen({
    Key? key,
    required this.userDTO,
    required this.shipper,
  }) : super(key: key);

  final UserDTO userDTO;
  final Shipper shipper;

  @override
  State<EditShipperScreen> createState() => _EditShipperScreenState();
}

class _EditShipperScreenState extends State<EditShipperScreen> {
  final _formEditCustomerInfoKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberPlateController = TextEditingController();

  bool _isEditing = false;

  Timer? _initTimer;

  late UserDTO _userDTO;
  late Shipper _shipper;

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

  bool _isValidEmail(String? email) {
    RegExp validRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+');
    if (email == null) {
      return false;
    }
    return validRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String? phoneNumber) {
    // Regular expression pattern to match valid phone numbers
    String pattern =
        r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-6]|9[0-46-9])[0-9]{7}$|^(0|\+84)(2[0-9]{1}|[3-9]{1})[0-9]{8}$';
    RegExp regExp = RegExp(pattern);

    if (phoneNumber == null) {
      return false;
    }
    // Check if the phone number matches the pattern
    if (regExp.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  _onSavePressed() async {
    if (_formEditCustomerInfoKey.currentState!.validate()) {
      final userServices = UserServices();
      final userUpdateDTO = UserUpdateDTO(
        id: _userDTO!.id,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );

      final shipperServices = ShipperServices();
      final shipperUpdateDTO = ShipperUpdateDTO(
        userId: _shipper.userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        middleName: _middleNameController.text,
        vehicleNumberPlate: _vehicleNumberPlateController.text,
        vehicleType: _vehicleTypeController.text,
        rating: _shipper.rating,
      );

      var isSuccess = await userServices.update(_userDTO.id, userUpdateDTO);
      isSuccess &=
          await shipperServices.update(_shipper.userId, shipperUpdateDTO);

      if (!isSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to update your account at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
      }

      List<Object> popObjects = [];
      popObjects.add(userUpdateDTO);
      popObjects.add(shipperUpdateDTO);

      _showAlertDialog(
        'Success',
        'We have successfully updated your account.',
        () {
          Navigator.pop(context);
          Navigator.pop(context, popObjects);
        },
      );
    }
  }

  bool _isValidVietnamesePlate(String plate) {
    final pattern = RegExp(r'^\d{2}-[A-Z]\d\s?\d{3,4}(\.\d{2})?$');
    return pattern.hasMatch(plate);
  }

  @override
  void initState() {
    super.initState();
    _userDTO = widget.userDTO;
    _shipper = widget.shipper;

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userDTO = widget.userDTO;
    _shipper = widget.shipper;
    _phoneNumberController.text = _userDTO.phoneNumber;
    _emailController.text = _userDTO.email;
    _firstNameController.text = _shipper.firstName;
    _middleNameController.text = _shipper.middleName;
    _lastNameController.text = _shipper.lastName;
    _vehicleNumberPlateController.text = _shipper.vehicleNumberPlate;
    _vehicleTypeController.text = _shipper.vehicleType;

    final userServices = UserServices();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.kPrimaryColor,
        foregroundColor: KColors.kOnBackgroundColor,
        title: const Text('FoodToGo - Shippers'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: KColors.kPrimaryColor,
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                'Edit your profile',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kOnBackgroundColor,
                      fontSize: 34,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
              child: Form(
                key: _formEditCustomerInfoKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.badge,
                          size: 27,
                          color: KColors.kTextColor,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new last name'),
                            ),
                            controller: _lastNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid last name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            decoration: const InputDecoration(
                              label: Text('Enter your new middle name'),
                            ),
                            controller: _middleNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid middle name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            decoration: const InputDecoration(
                              label: Text('Enter your new first name'),
                            ),
                            controller: _firstNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid first name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new phone number'),
                            ),
                            keyboardType: TextInputType.phone,
                            controller: _phoneNumberController,
                            validator: (value) {
                              if (_isValidPhoneNumber(value)) {
                                return null;
                              }
                              return 'Please enter a valid phone number.';
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new email'),
                            ),
                            controller: _emailController,
                            validator: (value) {
                              if (_isValidEmail(value)) {
                                return null;
                              }
                              return 'Please enter a valid email.';
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
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
                              label:
                                  Text('Enter your new vehicle number plate'),
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _onSavePressed();
                      },
                      child: _isEditing
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Save'),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
