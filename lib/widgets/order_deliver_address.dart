import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
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

  _navigateToRatingScreen(
      {required BuildContext context,
      required UserType fromUserType,
      required UserType toUserType,
      required Order order}) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RatingUserScreen(
              order: order, fromUserType: fromUserType, toUserType: toUserType),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShowingRatingButton =
        order.status != OrderStatus.Placed.name.toLowerCase();

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
                leading: const Icon(Icons.person_outline),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.customer.lastName} ${order.customer.middleName} ${order.customer.firstName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: order.customer.rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                trailing: Transform.translate(
                  offset: const Offset(10, 2),
                  child: !isShowingRatingButton
                      ? null
                      : RatingButton(
                          onButtonPressed: () {
                            _navigateToRatingScreen(
                                context: context,
                                fromUserType: UserType.Shipper,
                                toUserType: UserType.Customer,
                                order: order);
                          },
                        ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
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
