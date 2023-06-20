import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_shippers/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/enum/user_type.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/screens/current_accepted_order_screen.dart';
import 'package:foodtogo_shippers/services/accepted_order_services.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/order_deliver_address.dart';
import 'package:foodtogo_shippers/widgets/order_menu_item_list.dart';
import 'package:foodtogo_shippers/widgets/order_merchant.dart';
import 'package:foodtogo_shippers/widgets/order_price_widget.dart';
import 'package:foodtogo_shippers/widgets/order_shipper.dart';
import 'package:foodtogo_shippers/widgets/order_status_widget.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMMMMd();

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
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

  _isAbleToCancel(Order order) {
    if (order.status == OrderStatus.Placed.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.Getting.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return true;
    }
    return false;
  }

  _isShowingAcceptButton(Order order) {
    return order.status == OrderStatus.Placed.name.toLowerCase();
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
      cancelledBy: UserType.Merchant.name.toLowerCase(),
      cancellationReason: reason,
      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
    );
    final OrderServices orderServices = OrderServices();

    bool isSuccess = await orderServices.update(order.id, updateDTO);

    final orderList =
        await orderServices.getAll(merchantId: order.merchant.merchantId);

    isSuccess &= (orderList != null);

    if (isSuccess) {
      _showAlertDialog('Cancelled', 'The order has been cancelled', () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
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

  _onAcceptOrderTap(Order order) async {
    final acceptedOrderServices = AcceptedOrderServices();
    final currentOrder =
        await acceptedOrderServices.getCurrentOrderId(UserServices.userId!);

    if (currentOrder != 0) {
      _showAlertDialog('Cannot Accept New Order',
          'You have not finished delivering a previous order. Please finish it before accepting a new one.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      return;
    }

    final orderServices = OrderServices();

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
        status: OrderStatus.Getting.name.toLowerCase(),
        cancellationReason: order.cancellationReason,
        cancelledBy: order.cancelledBy,
        deliveryAddress: order.deliveryAddress,
        deliveryLongitude: order.deliveryLongitude,
        deliveryLatitude: order.deliveryLatitude);

    final isUpdateSuccess =
        await orderServices.update(order.id, orderUpdateDTO);

    if (isUpdateSuccess) {
      final isOrderStored =
          await acceptedOrderServices.insert(UserServices.userId!, order.id);

      if (context.mounted && isOrderStored) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => CurrentAcceptedOrderScreen(orderId: order.id),
        ));
      }
    } else {
      _showAlertDialog('Cannot Accept Order',
          'We are experiencing an error. Please try again later.', () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //get order details
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAbleToCancel = _isAbleToCancel(widget.order);
    final isShowingAcceptButton = _isShowingAcceptButton(widget.order);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order.merchant.name,
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: double.infinity,
        color: KColors.kPrimaryColor.withOpacity(0.2),
        child: ListView(
          children: [
            //Order status
            OrderStatusWidget(order: widget.order),
            //Customer
            const SizedBox(height: 20),
            OrderDeliverAddress(order: widget.order),
            //Merchant
            const SizedBox(height: 20),
            OrderMerchant(order: widget.order),
            //Shipper
            const SizedBox(height: 20),
            OrderShipper(order: widget.order),
            //Order details
            const SizedBox(height: 20),
            OrderMenuItemList(orderId: widget.order.id),
            //Order Price
            const SizedBox(height: 20),
            OrderPriceWidget(order: widget.order),

            if (isAbleToCancel && !isShowingAcceptButton)
              const SizedBox(height: 30),
            if (isAbleToCancel && !isShowingAcceptButton)
              ElevatedButton(
                  onPressed: () {
                    _showCancellationBottomSheet(context, widget.order);
                  },
                  child: const Text('Cancel Order')),

            if (isShowingAcceptButton) const SizedBox(height: 30),
            if (isShowingAcceptButton)
              ElevatedButton(
                onPressed: () {
                  _onAcceptOrderTap(widget.order);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Accept Order',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
