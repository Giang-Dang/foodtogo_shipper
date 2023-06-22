import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/order_deliver_address.dart';
import 'package:foodtogo_shippers/widgets/order_menu_item_list.dart';
import 'package:foodtogo_shippers/widgets/order_merchant.dart';
import 'package:foodtogo_shippers/widgets/order_price_widget.dart';
import 'package:foodtogo_shippers/widgets/order_shipper.dart';
import 'package:foodtogo_shippers/widgets/order_status_widget.dart';

class CurrentAcceptedOrderDetailsScreen extends StatelessWidget {
  const CurrentAcceptedOrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.merchant.name,
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: double.infinity,
        color: KColors.kSuperLightTextColor,
        // color: KColors.kPrimaryColor.withOpacity(0.2),
        child: ListView(
          children: [
            //Order status
            OrderStatusWidget(order: order),
            //Customer
            const SizedBox(height: 20),
            OrderDeliverAddress(order: order),
            //Merchant
            const SizedBox(height: 20),
            OrderMerchant(order: order),
            //Shipper
            const SizedBox(height: 20),
            OrderShipper(order: order),
            //Order details
            const SizedBox(height: 20),
            OrderMenuItemList(orderId: order.id),
            //Order Price
            const SizedBox(height: 20),
            OrderPriceWidget(order: order),
          ],
        ),
      ),
    );
  }
}
