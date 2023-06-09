
import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/models/enum/order_status.dart';
import 'package:foodtogo_shippers/models/order.dart';
import 'package:foodtogo_shippers/services/order_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/order_list_item.dart';

class AvailableOrdersWidget extends StatefulWidget {
  const AvailableOrdersWidget({Key? key}) : super(key: key);

  @override
  State<AvailableOrdersWidget> createState() => _AvailableOrdersWidgetState();
}

class _AvailableOrdersWidgetState extends State<AvailableOrdersWidget> {
  final _distanceTextController = TextEditingController();
  final _formDistanceKey = GlobalKey<FormState>();

  Future<List<Order>> _getOrders(double? inputDistance) async {
    double distance = 10.0;
    if (inputDistance != null) {
      distance = inputDistance;
    }
    if (_formDistanceKey.currentState != null) {
      if (!_formDistanceKey.currentState!.validate()) {
        return [];
      }
    }

    final userServices = UserServices();
    await userServices.getUserLocation();

    List<Order> orderList = [];

    final orderServices = OrderServices();

    orderList = await orderServices.getAll(
          searchStatus: OrderStatus.Placed.name,
          startLatitude: UserServices.currentLatitude,
          startLongitude: UserServices.currentLongitude,
          searchDistanceInKm: distance,
        ) ??
        [];

    return orderList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _distanceTextController.text = '10';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColors.kBackgroundColor,
      child: FutureBuilder(
        future: _getOrders(double.tryParse(_distanceTextController.text)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            return ListView(
              shrinkWrap: false,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Form(
                    key: _formDistanceKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Text(
                            'Search distance:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: KColors.kTextColor,
                                ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          fit: FlexFit.tight,
                          child: TextFormField(
                            controller: _distanceTextController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              suffixText: 'km',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid distance.';
                              }

                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid distance.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (_formDistanceKey.currentState!.validate()) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (snapshot.data != null)
                  snapshot.data!.isEmpty
                      ? const SizedBox(
                          height: 400,
                          child: Center(
                              child: Text(
                            'There are currently no available orders.',
                            style: TextStyle(fontSize: 16),
                          )),
                        )
                      : Container(),
                for (var order in snapshot.data!) OrderListItem(order: order),
              ],
            );
          }
        },
      ),
    );
  }
}
