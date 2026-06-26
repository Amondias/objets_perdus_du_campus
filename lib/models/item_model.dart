/// Represents a lost or found object publication.
class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;    // matches AppConfig.categories id
  final String type;        // 'lost' | 'found'
  final String status;      // 'pending' | 'active' | 'resolved'
  final List<String> photos; // URLs (Firebase Storage or local paths)
  final ItemLocation location;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.status = 'active',
    this.photos = const [],
    required this.location,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  bool get isResolved => status == 'resolved';
  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id:          map['id'] as String? ?? '',
      title:       map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category:    map['category'] as String? ?? 'other',
      type:        map['type'] as String? ?? 'lost',
      status:      map['status'] as String? ?? 'active',
      photos:      List<String>.from(map['photos'] as List? ?? []),
      location:    ItemLocation.fromMap(
                     map['location'] as Map<String, dynamic>? ?? {}),
      userId:      map['userId'] as String? ?? '',
      userName:    map['userName'] as String? ?? 'Anonyme',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      createdAt:   _parseDate(map['createdAt']),
      updatedAt:   _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'title':       title,
      'description': description,
      'category':    category,
      'type':        type,
      'status':      status,
      'photos':      photos,
      'location':    location.toMap(),
      'userId':      userId,
      'userName':    userName,
      'userPhotoUrl': userPhotoUrl,
      'createdAt':   createdAt,
      'updatedAt':   updatedAt,
    };
  }

  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? status,
    List<String>? photos,
    ItemLocation? location,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id:          id ?? this.id,
      title:       title ?? this.title,
      description: description ?? this.description,
      category:    category ?? this.category,
      type:        type ?? this.type,
      status:      status ?? this.status,
      photos:      photos ?? this.photos,
      location:    location ?? this.location,
      userId:      userId ?? this.userId,
      userName:    userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      createdAt:   createdAt ?? this.createdAt,
      updatedAt:   updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ItemModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ItemModel(id: $id, title: $title, type: $type)';
}

/// Geographic location of a lost/found item.
class ItemLocation {
  final double latitude;
  final double longitude;
  final String name; // e.g. "Amphi A, Bâtiment 3"

  const ItemLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory ItemLocation.fromMap(Map<String, dynamic> map) {
    return ItemLocation(
      latitude:  (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      name:      map['name'] as String? ?? 'Campus',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude':  latitude,
      'longitude': longitude,
      'name':      name,
    };
  }

  @override
  String toString() => 'ItemLocation($name, $latitude, $longitude)';
}
