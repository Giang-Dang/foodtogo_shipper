import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/dto/user_dto.dart';
import 'package:foodtogo_shippers/models/shipper.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
