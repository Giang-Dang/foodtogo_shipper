import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/order_list_item.dart';

class CompletedOrdersWidget extends StatefulWidget {
  const CompletedOrdersWidget({Key? key}) : super(key: key);

  @override
  State<CompletedOrdersWidget> createState() => _CompletedOrdersWidgetState();
}

class _CompletedOrdersWidgetState extends State<CompletedOrdersWidget> {
  Future<List<Order>> _getCancelledOrders() async {
    List<Order> orderList = [];

    final orderServices = OrderServices();

    orderList = await orderServices.getAll(
          shipperId: UserServices.userId,
          searchStatus: OrderStatus.Completed.name,
        ) ??
        [];

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
      future: _getCancelledOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: KColors.kBackgroundColor,
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        } else {
          return Container(
            color: KColors.kBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  snapshot.data!.isEmpty
                      ? const SizedBox(
                          height: 400,
                          child: Center(
                              child: Text(
                            'There are currently no completed orders.',
                            style: TextStyle(fontSize: 16),
                          )),
                        )
                      : Container(),
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
