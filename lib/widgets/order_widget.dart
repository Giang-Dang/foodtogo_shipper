import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/order_list_item.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key}) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  Future<List<Order>> _getUserOrders() async {
    final orderServices = OrderServices();

    List<Order> orderList = [];

    List<Future> futures = [];
    OrderStatus.values.forEach((element) {
      if (element != OrderStatus.Completed &&
          element != OrderStatus.Completed) {
        futures.add(() async {
          orderList = [
            ...await orderServices.getAll(
                  customerId: UserServices.userId,
                  searchStatus: element.name,
                ) ??
                []
          ];
        }());
      }
    });
    await Future.wait(futures);

    return orderList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return Container(
            color: KColors.kBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var order in snapshot.data!) OrderListItem(order: order),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
