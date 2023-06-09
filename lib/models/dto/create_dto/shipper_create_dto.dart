class ShipperCreateDTO {
  final int userId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String vehicleType;
  final String vehicleNumberPlate;
  final double rating;

  ShipperCreateDTO({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.vehicleType,
    required this.vehicleNumberPlate,
    this.rating = 0,
  });

  factory ShipperCreateDTO.fromJson(Map<String, dynamic> json) {
    return ShipperCreateDTO(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      vehicleType: json['vehicleType'],
      vehicleNumberPlate: json['vehicleNumberPlate'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'vehicleType': vehicleType,
        'vehicleNumberPlate': vehicleNumberPlate,
        'rating': rating,
      };
}
