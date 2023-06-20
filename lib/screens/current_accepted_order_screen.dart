import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/dto/create_dto/online_shipper_status_create_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/online_shipper_status_update_dto.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/enum/user_type.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/screens/current_accepted_order_details_screen.dart';
import 'package:foodtogo_shippers/screens/tabs_screen.dart';
import 'package:foodtogo_shippers/services/accepted_order_services.dart';
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

  _onCancelPress(Order order, String reason) async {
    final updateDTO = OrderUpdateDTO(
      id: order.id,
      merchantId: order.merchant.merchantId,
      shipperId: order.shipper == null ? null : order.shipper!.userId,
      customerId: order.customer.customerId,
      promotionId: order.promotion == null ? null : order.promotion!.id,
      placedTime: order.placedTime,
      eta: order.eta,
      deliveryCompletionTime: order.deliveryCompletionTime,
      orderPrice: order.orderPrice,
      shippingFee: order.shippingFee,
      appFee: order.appFee,
      promotionDiscount: order.promotionDiscount,
      status: OrderStatus.Cancelled.name.toLowerCase(),
      cancelledBy: UserType.Shipper.name.toLowerCase(),
      cancellationReason: reason,
      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
    );
    final OrderServices orderServices = OrderServices();

    bool isSuccess = await orderServices.update(order.id, updateDTO);

    final acceptedOrderServices = AcceptedOrderServices();
    isSuccess &=
        await acceptedOrderServices.delete(UserServices.currentOrderId);

    if (isSuccess) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const TabsScreen(),
        ));
      }
    } else {
      _showAlertDialog('Cancellation failed',
          'Unable to cancel this order at the moment. Please try again later.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  _showCancellationBottomSheet(
    BuildContext context,
    Order order,
  ) async {
    final TextEditingController controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please enter a cancellation reason:',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: KColors.kPrimaryColor),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(hintText: 'Cancellation reason'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text == '') {
                      _showAlertDialog('Invalid Reason',
                          'The reason field cannot be left empty!', () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                      return;
                    }
                    // Return the cancellation reason
                    String? reason = controller.text;

                    await _onCancelPress(order, reason);
                  },
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onOrderDetailsTap() {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CurrentAcceptedOrderDetailsScreen(order: _order!),
      ));
    }
  }

  Future<bool?> _updateNextStatus(Order order) async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    final isOrderCancelled = await _isOrderCancelled(order.id);
    if (isOrderCancelled) {
      final acceptedOrderServices = AcceptedOrderServices();
      final isOrderDeleted =
          await acceptedOrderServices.delete(UserServices.userId!);

      _showAlertDialog('Order Cancelled',
          'The order has been cancelled.\nCancelled by: ${order.cancelledBy} \n Reason: ${order.cancellationReason}',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ));
        }
      });

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return null;
    }
    if (_isUpdatingLocation) {
      _showAlertDialog(
          'Updating location', 'Location is updating. Please wait...', () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return null;
    }

    final orderServices = OrderServices();
    final locationServices = LocationServices();

    final nextOrderStatus =
        OrderStatus.values[orderServices.getOrderStatusIndex(order.status) + 1];

    if (nextOrderStatus.index == OrderStatus.DriverAtDeliveryPoint.index) {
      await _updateLocation();
      final distance = locationServices.calculateDistance(
        UserServices.currentLatitude,
        UserServices.currentLongitude,
        order.deliveryLatitude,
        order.deliveryLongitude,
      );

      if (distance > 0.5) {
        _showAlertDialog('Cannot Proccess To Next Step',
            'Your location is not near the delivery point.', () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return false;
      }

      final isUpdateOrderStatusSuccess =
          await _updateOrderStatus(order, nextOrderStatus);

      //re-initialize
      await _initialize();

      return isUpdateOrderStatusSuccess;
    }

    if (nextOrderStatus.index == OrderStatus.DriverAtMerchant.index) {
      await _updateLocation();
      final distance = locationServices.calculateDistance(
        UserServices.currentLatitude,
        UserServices.currentLongitude,
        order.merchant.geoLatitude,
        order.merchant.geoLongitude,
      );

      if (distance > 0.5) {
        _showAlertDialog('Cannot Proccess To Next Step',
            'Your location is not near the merchant.', () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return false;
      }

      final isUpdateOrderStatusSuccess =
          await _updateOrderStatus(order, nextOrderStatus);
      //re-initialize
      await _initialize();

      return isUpdateOrderStatusSuccess;
    }

    if (nextOrderStatus.index == OrderStatus.Completed.index) {
      final isUpdateOrderStatusSuccess =
          await _updateOrderStatus(order, nextOrderStatus);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const TabsScreen(),
        ));
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return isUpdateOrderStatusSuccess;
    }

    final isUpdateOrderStatusSuccess =
        await _updateOrderStatus(order, nextOrderStatus);
    //re-initialize
    await _initialize();
    return true;
  }

  Future<bool?> _updatePreviousStatus(Order order) async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    final isOrderCancelled = await _isOrderCancelled(order.id);
    if (isOrderCancelled) {
      final acceptedOrderServices = AcceptedOrderServices();
      final isOrderDeleted =
          await acceptedOrderServices.delete(UserServices.userId!);

      _showAlertDialog('Order Cancelled',
          'The order has been cancelled.\nCancelled by: ${order.cancelledBy} \n Reason: ${order.cancellationReason}',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ));
        }
      });
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return null;
    }
    if (_isUpdatingLocation) {
      _showAlertDialog(
          'Updating location', 'Location is updating. Please wait...', () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return null;
    }

    final orderServices = OrderServices();
    final locationServices = LocationServices();

    final previousOrderStatus =
        OrderStatus.values[orderServices.getOrderStatusIndex(order.status) - 1];

    if (previousOrderStatus.index == OrderStatus.DriverAtDeliveryPoint.index) {
      await _updateLocation();
      final distance = locationServices.calculateDistance(
        UserServices.currentLatitude,
        UserServices.currentLongitude,
        order.deliveryLatitude,
        order.deliveryLongitude,
      );

      if (distance > 0.1) {
        _showAlertDialog('Cannot Proccess To Next Step',
            'Your location is not near the delivery point.', () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return false;
      }

      var isUpdateOrderStatusSuccess =
          await _updateOrderStatus(order, previousOrderStatus);

      //re-initialize
      await _initialize();
      return isUpdateOrderStatusSuccess;
    }

    if (previousOrderStatus.index == OrderStatus.DriverAtMerchant.index) {
      await _updateLocation();
      final distance = locationServices.calculateDistance(
        UserServices.currentLatitude,
        UserServices.currentLongitude,
        order.merchant.geoLatitude,
        order.merchant.geoLongitude,
      );

      if (distance > 0.1) {
        _showAlertDialog('Cannot Proccess To Next Step',
            'Your location is not near the merchant.', () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return false;
      }

      final isUpdateOrderStatusSuccess =
          await _updateOrderStatus(order, previousOrderStatus);
      //re-initialize
      await _initialize();

      return isUpdateOrderStatusSuccess;
    }

    var isUpdateOrderStatusSuccess =
        await _updateOrderStatus(order, previousOrderStatus);

    //re-initialize
    await _initialize();

    return true;
  }

  _updateLocation() async {
    _isUpdatingLocation = true;

    final locationServices = LocationServices();
    final userServices = UserServices();
    await userServices.getUserLocation();

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

  Future<bool> _isOrderCancelled(int orderId) async {
    final orderServices = OrderServices();

    final orderDTO = await orderServices.getDTO(orderId);

    if (orderDTO == null) {
      log('_isOrderCancelled orderDTO == null');
      return true;
    }

    if (orderDTO.status.toLowerCase() ==
        OrderStatus.Cancelled.name.toLowerCase()) {
      return true;
    }

    return false;
  }

  Future<bool> _updateOrderStatus(
      Order order, OrderStatus newOrderStatus) async {
    final orderServices = OrderServices();
    final acceptedOrderServices = AcceptedOrderServices();

    final orderUpdateDTO = OrderUpdateDTO(
        id: order.id,
        merchantId: order.merchant.merchantId,
        shipperId: UserServices.userId,
        customerId: order.customer.customerId,
        promotionId: order.promotion == null ? null : order.promotion!.id,
        placedTime: order.placedTime,
        eta: order.eta,
        deliveryCompletionTime: order.deliveryCompletionTime,
        orderPrice: order.orderPrice,
        shippingFee: order.shippingFee,
        appFee: order.appFee,
        promotionDiscount: order.promotionDiscount,
        status: newOrderStatus.name.toLowerCase(),
        cancellationReason: order.cancellationReason,
        cancelledBy: order.cancelledBy,
        deliveryAddress: order.deliveryAddress,
        deliveryLongitude: order.deliveryLongitude,
        deliveryLatitude: order.deliveryLatitude);

    final isUpdateSuccess =
        await orderServices.update(order.id, orderUpdateDTO);

    if (newOrderStatus.index == OrderStatus.Completed.index - 1) {
      if (isUpdateSuccess) {
        final isOrderDeleted =
            await acceptedOrderServices.delete(UserServices.userId!);
        return isOrderDeleted;
      }
    }

    if (newOrderStatus.index == OrderStatus.Cancelled.index - 1) {
      if (isUpdateSuccess) {
        final isOrderDeleted =
            await acceptedOrderServices.delete(UserServices.userId!);
        return isOrderDeleted;
      }
    }
    return isUpdateSuccess;
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
                      final isSuccess = await _updateNextStatus(_order!);
                      if (isSuccess == null) {
                        return;
                      }
                    }
                  : null,
              onStepCancel: _currentStep > 0
                  ? () async {
                      final isSuccess = await _updatePreviousStatus(_order!);
                      if (isSuccess == null) {
                        return;
                      }
                    }
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
            onPressed: () {
              _showCancellationBottomSheet(context, _order!);
            },
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
