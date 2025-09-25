class JobRecord {
  JobRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.service,
    required this.details,
    required this.address,
    required this.lat,
    required this.lng,
    required this.price,
    required this.pricingType,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
    this.tags = const [],
    this.schedule,
    this.image = '',
  });

  final String id;
  final String title;
  final String category;
  final String service;
  final String details;
  final String address;
  final double lat;
  final double lng;
  final num price;
  final String pricingType;
  final String contactName;
  final String contactPhone;
  final DateTime createdAt;
  final List<String> tags;
  final Map<String, dynamic>? schedule;
  final String image; // <-- add this

  factory JobRecord.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final coordinates = (location?['coordinates'] as List?)?.cast<num>();
    final parsedLat = (json['lat'] as num?)?.toDouble();
    final parsedLng = (json['lng'] as num?)?.toDouble();
    final fallbackLat = (coordinates != null && coordinates.length >= 2)
        ? coordinates[1].toDouble()
        : 0.0;
    final fallbackLng = (coordinates != null && coordinates.length >= 2)
        ? coordinates[0].toDouble()
        : 0.0;

    return JobRecord(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      service: json['service']?.toString() ?? (json['serviceName']?.toString() ?? ''),
      details: json['details']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: parsedLat ?? fallbackLat,
      lng: parsedLng ?? fallbackLng,
      price: (json['price'] as num?) ?? 0,
      pricingType: json['pricingType']?.toString() ?? '',
      contactName: json['contactName']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      schedule: json['schedule'] as Map<String, dynamic>?,
      image: json['image']?.toString() ?? '', // <-- parse image
    );
  }
}

class ServiceItem {
  ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    this.normalizedName = '',
    this.image = '',
  });

  final String id;
  final String name;
  final String category;
  final List<String> tags;
  final String normalizedName;
  final String image; // <-- add this

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      normalizedName: json['normalizedName']?.toString() ?? '',
      image: json['image']?.toString() ?? '', // <-- parse image
    );
  }
}

class ServicesResponse {
  ServicesResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.timestamp,
    required this.count,
    required this.rowcount,
    required this.records,
    required this.totalCount,
    required this.statusbool,
    required this.ok,
  });

  final String status;
  final int statusCode;
  final String message;
  final String timestamp;
  final int count;
  final int rowcount;
  final List<ServiceItem> records;
  final int totalCount;
  final bool statusbool;
  final bool ok;

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    return ServicesResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code'] ?? 0,
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      count: json['count'] ?? 0,
      rowcount: json['rowcount'] ?? 0,
      records:
          (json['records'] as List?)
              ?.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      statusbool: json['statusbool'] ?? false,
      ok: json['ok'] ?? false,
    );
  }
}

class JobPostRequest {
  JobPostRequest({
    required this.title,
    required this.category,
    required this.service,
    required this.serviceId,
    required this.details,
    required this.tags,
    required this.address,
    required this.lat,
    required this.lng,
    required this.pricingType,
    required this.price,
    required this.contactName,
    required this.contactPhone,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.specificDates,
    required this.scheduleType,
  });

  final String title;
  final String category;
  final String service;
  final String serviceId;
  final String details;
  final List<String> tags;
  final String address;
  final double lat;
  final double lng;
  final String pricingType;
  final num price;
  final String contactName;
  final String contactPhone;
  final String startDate;
  final String endDate;
  final List<int> daysOfWeek;
  final List<String> specificDates;
  final String scheduleType;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'service': service,
      'serviceId': serviceId,
      'details': details,
      'tags': tags,
      'address': address,
      'lat': lat,
      'lng': lng,
      'pricingType': pricingType,
      'price': price,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek,
      'specificDates': specificDates,
      'scheduleType': scheduleType,
    };
  }
}

class AddressData {
  AddressData({
    this.buildingNumber = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.lat = 0.0,
    this.lng = 0.0,
  });

  final String buildingNumber;
  final String area;
  final String city;
  final String state;
  final String country;
  final double lat;
  final double lng;

  String get fullAddress {
    final parts = <String>[];
    if (buildingNumber.isNotEmpty) parts.add(buildingNumber);
    if (area.isNotEmpty) parts.add(area);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  AddressData copyWith({
    String? buildingNumber,
    String? area,
    String? city,
    String? state,
    String? country,
    double? lat,
    double? lng,
  }) {
    return AddressData(
      buildingNumber: buildingNumber ?? this.buildingNumber,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
