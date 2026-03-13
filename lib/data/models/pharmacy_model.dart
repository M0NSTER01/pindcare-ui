class PharmacyModel {
  final String id;
  final String name;
  final String type; // government, private, hospital
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String hours;
  final bool isOpen;
  final bool is24Hours;
  final double distance; // in km
  final List<MedicineStockModel> medicines;
  final DateTime lastUpdated;
  // Backend stock-freshness fields
  final bool isLive;       // pharmacy actively updated in last 5 min
  final int minutesAgo;    // minutes since last stock update
  final DateTime? lastSeen; // exact timestamp of last update

  PharmacyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.hours,
    this.isOpen = true,
    this.is24Hours = false,
    this.distance = 0,
    this.medicines = const [],
    DateTime? lastUpdated,
    this.isLive = false,
    this.minutesAgo = 999,
    this.lastSeen,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'address': address,
        'lat': lat,
        'lng': lng,
        'phone': phone,
        'hours': hours,
        'isOpen': isOpen,
        'is24Hours': is24Hours,
        'distance': distance,
        'medicines': medicines.map((m) => m.toMap()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory PharmacyModel.fromMap(Map<String, dynamic> map) => PharmacyModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? 'private',
        address: map['address'] ?? '',
        lat: (map['lat'] ?? 0.0).toDouble(),
        lng: (map['lng'] ?? map['lon'] ?? 0.0).toDouble(),
        phone: map['phone'] ?? '',
        hours: map['hours'] ?? '',
        isOpen: map['isOpen'] ?? map['is_open'] ?? true,
        is24Hours: map['is24Hours'] ?? false,
        distance: (map['distance'] ?? 0.0).toDouble(),
        medicines: (map['medicines'] as List?)
                ?.map((m) => MedicineStockModel.fromMap(Map<String, dynamic>.from(m)))
                .toList() ??
            [],
        lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? map['last_updated'] ?? '') ?? DateTime.now(),
        isLive: map['isLive'] ?? map['is_live'] ?? false,
        minutesAgo: map['minutesAgo'] ?? map['minutes_ago'] ?? 999,
        lastSeen: DateTime.tryParse(map['lastSeen'] ?? map['last_seen'] ?? ''),
      );
}

class MedicineStockModel {
  final String id;
  final String name;
  final String? genericName;
  final String stockStatus; // inStock, outOfStock, lowStock, unknown
  final String price;
  final DateTime lastUpdated;

  MedicineStockModel({
    required this.id,
    required this.name,
    this.genericName,
    this.stockStatus = 'unknown',
    required this.price,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'genericName': genericName,
        'stockStatus': stockStatus,
        'price': price,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory MedicineStockModel.fromMap(Map<String, dynamic> map) => MedicineStockModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        genericName: map['genericName'],
        stockStatus: map['stockStatus'] ?? 'unknown',
        price: map['price'] ?? '₹0',
        lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      );
}
