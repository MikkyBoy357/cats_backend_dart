import 'package:cats_backend/common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Event {
  ObjectId id;
  String name;
  String owner;
  String description;
  String location;
  DateTime date;
  List<EventCategory> categories;
  List<TicketType> ticketTypes;
  User createdBy;
  DateTime createdAt;

  // New fields for engagement tracking
  int views;
  int clicks;
  int shares;
  int bookmarks;
  DateTime lastUpdated;
  List<String> mediaUrls;

  Event({
    required this.id,
    required this.name,
    required this.owner,
    required this.description,
    required this.location,
    required this.date,
    required this.categories,
    required this.ticketTypes,
    required this.createdBy,
    required this.createdAt,
    this.views = 0,
    this.clicks = 0,
    this.shares = 0,
    this.bookmarks = 0,
    required this.lastUpdated,
    required this.mediaUrls,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    printMagenta('Categories: ${json['categories']}');
    return Event(
      id: toObjectId(json['_id']),
      name: json['name'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      categories: (json['categories'] as List)
          .map((e) => EventCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      ticketTypes: (json['ticketTypes'] as List)
          .map((e) => TicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: User.fromJson(
        json['createdBy'] as Map<String, dynamic>,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      clicks: int.tryParse(json['clicks']?.toString() ?? '0') ?? 0,
      shares: int.tryParse(json['shares']?.toString() ?? '0') ?? 0,
      bookmarks: int.tryParse(json['bookmarks']?.toString() ?? '0') ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
      mediaUrls: (json['mediaUrls'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'owner': owner,
      'description': description,
      'location': location,
      'date': date.toString(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'ticketTypes': ticketTypes.map((e) => e.toJson()).toList(),
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toString(),
      'views': views,
      'clicks': clicks,
      'shares': shares,
      'bookmarks': bookmarks,
      'lastUpdated': lastUpdated.toString(),
      'mediaUrls': mediaUrls,
    };
  }

  Event copyWith({
    ObjectId? id,
    String? name,
    String? owner,
    String? description,
    String? location,
    DateTime? date,
    List<EventCategory>? categories,
    List<TicketType>? ticketTypes,
    User? createdBy,
    DateTime? createdAt,
    int? views,
    int? clicks,
    int? shares,
    int? bookmarks,
    DateTime? lastUpdated,
    List<String>? mediaUrls,  // Added this parameter
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      categories: categories ?? this.categories,
      ticketTypes: ticketTypes ?? this.ticketTypes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      shares: shares ?? this.shares,
      bookmarks: bookmarks ?? this.bookmarks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }
}
class EventRequest {
  final String name;
  final String owner;
  final String description;
  final String location;
  final DateTime date;
  final List<ObjectId> categories;
  final List<ObjectId> ticketTypes;
  final ObjectId createdBy;
  final DateTime createdAt;

  EventRequest({
    required this.name,
    required this.owner,
    required this.description,
    required this.location,
    required this.date,
    required this.categories,
    required this.ticketTypes,
    required this.createdBy,
    required this.createdAt,
  });

  factory EventRequest.fromJson(Map<String, dynamic> json) {
    return EventRequest(
      name: json['name'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      categories:
          (json['categories'] as List).map((e) => toObjectId(e)).toList(),
      ticketTypes:
          (json['ticketTypes'] as List).map((e) => toObjectId(e)).toList(),
      createdBy: ObjectId.fromHexString(
        json['createdBy'] as String,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'description': description,
      'location': location,
      'date': date.toString(),
      'categories': categories,
      'ticketTypes': ticketTypes,
      'createdBy': createdBy,
      'createdAt': createdAt.toString(),
    };
  }
}
