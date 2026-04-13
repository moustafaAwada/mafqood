class UpdateLocationRequest {
  final double latitude;
  final double longitude;

  UpdateLocationRequest({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
