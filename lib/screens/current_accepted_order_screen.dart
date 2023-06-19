import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/dto/create_dto/online_shipper_status_create_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/online_shipper_status_update_dto.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/screens/current_accepted_order_details_screen.dart';
import 'package:foodtogo_shippers/services/location_services.dart';
import 'package:foodtogo_shippers/services/online_shipper_status_services.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';

class CurrentAcceptedOrderScreen extends StatefulWidget {
  const CurrentAcceptedOrderScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  final int orderId;

  @override
  State<CurrentAcceptedOrderScreen> createState() =>
      _CurrentAcceptedOrderScreenState();
}

class _CurrentAcceptedOrderScreenState
    extends State<CurrentAcceptedOrderScreen> {
  int _currentStep = 0;
  Order? _order;

  bool _isInitializing = true;
  bool _isUpdatingLocation = false;
  Timer? _initTimer;
  Timer? _updateLocationTimer;

  _initialize() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    final orderServices = OrderServices();
    final order = await orderServices.getById(widget.orderId);

    if (order == null) {
      log('_initialize order == null');
      return;
    }

    int currentStep = orderServices.getOrderStatusIndex(order.status) - 1;

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _currentStep = currentStep;
        _order = order;
      });
    }
  }

  _onCancelOrderTap() async {}

  _onOrderDetailsTap() {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CurrentAcceptedOrderDetailsScreen(order: _order!),
      ));
    }
  }

  Future<bool?> _updateNextStatus(Order order) async {
    if (_isUpdatingLocation) {
      _showAlertDialog(
          'Updating location', 'Location is updating. Please wait...', () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      return null;
    }

    final orderServices = OrderServices();
    final locationServices = LocationServices();

    if (orderServices.getOrderStatusIndex(order.status) ==
        OrderStatus.DriverAtDeliveryPoint.index - 1) {
      //do next
    }
  }

  _updateLocation() async {
    _isUpdatingLocation = true;

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

    _isUpdatingLocation = false;
  }

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    if (context.mounted) {
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
      _initTimer?.cancel();
    });

    _updateLocationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateLocation();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    _updateLocationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderServices = OrderServices();

    Widget bodyContent = const Center(
      child: CircularProgressIndicator.adaptive(),
    );

    if (!_isInitializing) {
      bodyContent = Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(children: [
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _currentStep < OrderStatus.values.length - 3
                  ? () async {
                      setState(() => _currentStep += 1);
                    }
                  : null,
              onStepCancel: _currentStep > 0
                  ? () => setState(() => _currentStep -= 1)
                  : null,
              steps: OrderStatus.values
                  .where((status) =>
                      status != OrderStatus.Placed &&
                      status != OrderStatus.Cancelled)
                  .map(
                    (status) => Step(
                      title: Text(
                        orderServices.getOrderStatusText(status.name),
                        style: TextStyle(
                            color: _currentStep ==
                                    OrderStatus.values.indexOf(status) - 1
                                ? KColors.kPrimaryColor
                                : null,
                            fontWeight: FontWeight.bold),
                      ),
                      content:
                          Text(orderServices.getOrderStatusInfo(status.name)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(color: KColors.kPrimaryColor),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: KColors.kOnBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                title: const Text('Order Details'),
                trailing: const Icon(
                  Icons.navigate_next,
                  color: KColors.kPrimaryColor,
                  size: 30,
                ),
                onTap: _onOrderDetailsTap,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: KColors.kPrimaryColor),
          ElevatedButton(
            onPressed: _onCancelOrderTap,
            child: const Text('Cancel Order'),
          ),
          const SizedBox(height: 80)
        ]),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Delivering...',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: KColors.kPrimaryColor,
                  fontSize: 28,
                ),
          ),
          centerTitle: true,
        ),
        body: bodyContent,
      ),
    );
  }
}
