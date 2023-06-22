import 'package:foodtogo_shippers/settings/kdelivery.dart';

class DeliveryServices {
  double calDeliveryETA(double distanceInKm) {
    return distanceInKm * KDelivery.kMinsPerKm + KDelivery.kPrepairTime;
  }
}
