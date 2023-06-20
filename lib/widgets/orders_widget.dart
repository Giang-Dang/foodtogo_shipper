import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/available_orders_widget.dart';
import 'package:foodtogo_shippers/widgets/cancelled_orders_widget.dart';
import 'package:foodtogo_shippers/widgets/completed_orders_widget.dart';

class OrdersWidget extends StatefulWidget {
  const OrdersWidget({Key? key}) : super(key: key);

  @override
  State<OrdersWidget> createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _tabColor;

  Color _getTabColor(int tabIndex) {
    if (tabIndex == 0) {
      return KColors.kBlue;
    }
    if (tabIndex == 1) {
      return KColors.kSuccessColor;
    }
    return KColors.kPrimaryColor;
  }

  _setTabColor() {
    if (mounted) {
      setState(() {
        _tabColor = _getTabColor(_tabController.index);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabColor = _getTabColor(0);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _setTabColor();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      color: KColors.kBackgroundColor,
      child: Column(
        children: [
          Container(
            height: 30,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: _tabColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: 'Available Orders'),
                  Tab(text: 'Completed Orders'),
                  Tab(text: 'Cancelled Orders'),
                ]),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: TabBarView(
              
              controller: _tabController,
              children: const [
                AvailableOrdersWidget(),
                CompletedOrdersWidget(),
                CancelledOrdersWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
