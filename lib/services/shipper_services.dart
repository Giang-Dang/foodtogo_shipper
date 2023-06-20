import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_shippers/models/dto/create_dto/shipper_create_dto.dart';
import 'package:foodtogo_shippers/models/dto/shipper_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/shipper_update_dto.dart';
import 'package:foodtogo_shippers/models/order_success_rate.dart';
import 'package:foodtogo_shippers/services/order_success_rate_services.dart';
import 'package:foodtogo_shippers/services/user_rating_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/secrets.dart';
import 'package:foodtogo_shippers/models/shipper.dart';
import 'package:http/http.dart' as http;

class ShipperServices {
  static const _apiUrl = 'api/ShipperAPI';

  Future<Shipper?> get(int shipperId) async {
    final UserServices userServices = UserServices();
    final UserRatingServices userRatingServices = UserRatingServices();
    final OrderSuccessRateServices orderSuccessRateServices =
        OrderSuccessRateServices();

    final shipperDTO = await getDTO(shipperId);
    final userDTO = await userServices.getDTO(shipperId);
    final rating = await userRatingServices.getAvgRating(shipperId, "Shipper");
    final OrderSuccessRate? orderSuccessRate =
        await orderSuccessRateServices.getSuccessRate(shipperId, "Shipper");

    if (shipperDTO != null &&
        userDTO != null &&
        rating != null &&
        orderSuccessRate != null) {
      return Shipper(
        userId: shipperDTO.userId,
        firstName: shipperDTO.firstName,
        lastName: shipperDTO.lastName,
        middleName: shipperDTO.middleName,
        vehicleType: shipperDTO.vehicleType,
        vehicleNumberPlate: shipperDTO.vehicleNumberPlate,
        phoneNumber: userDTO.phoneNumber,
        email: userDTO.email,
        rating: rating,
        successOrderCount: orderSuccessRate.successOrderCount,
        cancelledOrderCount: orderSuccessRate.cancelledOrderCount,
      );
    }
    return null;
  }

  Future<ShipperDTO?> getDTO(int shipperId) async {
    final newApiUrl = '$_apiUrl/$shipperId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      var shipperDTO = ShipperDTO(
        userId: responseObject['result']['userId'],
        firstName: responseObject['result']['firstName'],
        lastName: responseObject['result']['lastName'],
        middleName: responseObject['result']['middleName'],
        vehicleType: responseObject['result']['vehicleType'],
        vehicleNumberPlate: responseObject['result']['vehicleNumberPlate'],
        rating: responseObject['result']['rating'],
      );

      return shipperDTO;
    }
    return null;
  }

  Future<int> create(ShipperCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final requestJsonBody = json.encode(createDTO.toJson());

    final responseJson = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: requestJsonBody,
    );

    if (responseJson.statusCode != HttpStatus.created) {
      log('ShipperServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return 0;
    }

    final responseData = json.decode(responseJson.body);

    final createId = responseData['result']['userId'] as int;

    return createId;
  }

  Future<bool> update(int id, ShipperUpdateDTO updateDTO) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$_apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode(updateDTO.toJson());

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }
}
