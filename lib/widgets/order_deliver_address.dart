import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_shippers/models/enum/user_type.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/screens/rating_user_screen.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/rating_button.dart';

class OrderDeliverAddress extends StatelessWidget {
  const OrderDeliverAddress({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deliver Address',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: KColors.kLightTextColor,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: KColors.kOnBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  '${order.customer.lastName} ${order.customer.middleName} ${order.customer.firstName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(order.customer.phoneNumber),
              ),
              ListTile(
                leading: const Icon(Icons.pin_drop_outlined),
                title: Text(
                  order.deliveryAddress,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
