class FacilityModel {
  final String id;
  final String name;
  final String type; // hospital, clinic, pharmacy, doctor_clinic
  final double lat;
  final double lng;
  final String address;
  final String phone;
  final String hours;
  final bool isOpen;
  final double distance; // km
  final List<String> doctors;
  final String? photoUrl;
  final String syncStatus;

  FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.address,
    required this.phone,
    required this.hours,
    this.isOpen = true,
    this.distance = 0,
    this.doctors = const [],
    this.photoUrl,
    this.syncStatus = 'synced',
  });

  String get typeLabel {
    switch (type) {
      case 'hospital':
        return 'Hospital';
      case 'clinic':
        return 'Clinic';
      case 'pharmacy':
        return 'Pharmacy';
      case 'doctor_clinic':
        return "Doctor's Clinic";
      default:
        return 'Facility';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'hospital':
        return '🏥';
      case 'clinic':
        return '🏨';
      case 'pharmacy':
        return '💊';
      case 'doctor_clinic':
        return '👨‍⚕️';
      default:
        return '🏥';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'lat': lat,
        'lng': lng,
        'address': address,
        'phone': phone,
        'hours': hours,
        'isOpen': isOpen,
        'distance': distance,
        'doctors': doctors,
        'photoUrl': photoUrl,
        'syncStatus': syncStatus,
      };

  factory FacilityModel.fromMap(Map<String, dynamic> map) => FacilityModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? 'hospital',
        lat: (map['lat'] ?? 0.0).toDouble(),
        lng: (map['lng'] ?? 0.0).toDouble(),
        address: map['address'] ?? '',
        phone: map['phone'] ?? '',
        hours: map['hours'] ?? '',
        isOpen: map['isOpen'] ?? true,
        distance: (map['distance'] ?? 0.0).toDouble(),
        doctors: List<String>.from(map['doctors'] ?? []),
        photoUrl: map['photoUrl'],
        syncStatus: map['syncStatus'] ?? 'synced',
      );
}
