import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodtogo_shippers/services/online_shipper_status_services.dart';
import 'package:foodtogo_shippers/services/user_services.dart';
import 'package:foodtogo_shippers/settings/kcolors.dart';
import 'package:foodtogo_shippers/widgets/me_widget.dart';
import 'package:foodtogo_shippers/widgets/orders_widget.dart';

enum TabName { orders, me }

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  DateTime _timeBackPressed = DateTime.now();
  int _selectedPageIndex = 0;

  Widget _activePage = const OrdersWidget();
  bool _isAppBarShow = true;
  bool _isFloatingButtonShow = false;

  Timer? _initTimer;

  _deleteLocation() async {
    final onlineShipperStatusServices = OnlineShipperStatusServices();
    int userId = UserServices.userId ?? 0;
    if (userId != 0) {
      await onlineShipperStatusServices.delete(userId);
      log('didChangeAppLifecycleState complete');
    }
  }

  void _selectPage(int index) async {
    if (mounted) {
      setState(() {
        _selectedPageIndex = index;
        if (_selectedPageIndex == TabName.orders.index) {
          _activePage = const OrdersWidget();
          _isAppBarShow = true;
          _isFloatingButtonShow = false;
        } else if (_selectedPageIndex == TabName.me.index) {
          _activePage = const Me();
          _isAppBarShow = false;
          _isFloatingButtonShow = false;
        } else {
          _activePage = const OrdersWidget();
          _isAppBarShow = false;
          _isFloatingButtonShow = false;
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    final difference = DateTime.now().difference(_timeBackPressed);
    final isExitWarning = difference >= const Duration(seconds: 2);

    _timeBackPressed = DateTime.now();

    if (isExitWarning) {
      const message = 'Press back again to exit';
      Fluttertoast.showToast(msg: message, fontSize: 18);

      return false;
    } else {
      Fluttertoast.cancel();

      const message = 'Exiting the app. Please wait...';
      Fluttertoast.showToast(msg: message, fontSize: 18);

      await _deleteLocation();

      Fluttertoast.cancel();

      return true;
    }
  }

  _onFloatingActionButtonPressed() {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar? appBar = !_isAppBarShow
        ? null
        : AppBar(
            backgroundColor: KColors.kBackgroundColor,
            title: Text(
              'FoodToGo - Shipper',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 24,
                  ),
            ),
          );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: _activePage,
        floatingActionButton: _isFloatingButtonShow
            ? SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  onPressed: _onFloatingActionButtonPressed,
                  elevation: 10.0,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.refresh),
                ),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: KColors.kLightTextColor,
          unselectedFontSize: 10,
          selectedItemColor: KColors.kPrimaryColor,
          selectedFontSize: 12,
          showUnselectedLabels: true,
          currentIndex: _selectedPageIndex,
          onTap: (index) {
            _selectPage(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: KColors.kLightTextColor,
              ),
              label: 'Orders',
              activeIcon: Icon(
                Icons.receipt_long,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color: KColors.kLightTextColor,
              ),
              label: 'Me',
              activeIcon: Icon(
                Icons.person,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
