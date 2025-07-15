import 'package:cats_backend/common/common.dart';
import 'package:dartz/dartz.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Event {
  ObjectId id;
  String name;
  String owner;
  String description;
  String location;
  Visibility visibility;
  DateTime date;
  List<Either<ObjectId, EventCategory>> categories;
  List<Either<ObjectId, TicketType>> ticketTypes;
  Either<ObjectId, User> createdBy;
  DateTime createdAt;

  // New fields for engagement tracking
  int views;
  int clicks;
  int shares;
  int bookmarks;
  DateTime lastUpdated;
  List<String> mediaUrls;

  // Sales
  EventSales? sales;

  Event({
    required this.id,
    required this.name,
    required this.owner,
    required this.description,
    required this.location,
    this.visibility = Visibility.public,
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
    this.sales,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: toObjectId(json['_id']),
      name: json['name'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.public,
      ),
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      categories: parseEitherList<EventCategory>(
        json['categories'] as List,
        EventCategory.fromJson,
      ),
      ticketTypes: parseEitherList<TicketType>(
        json['ticketTypes'] as List,
        TicketType.fromJson,
      ),
      createdBy: parseEither<User>(json['createdBy'], User.fromJson),
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
      mediaUrls:
          (json['mediaUrls'] as List?)?.map((e) => e as String).toList() ?? [],
      sales: json['sales'] != null
          ? EventSales.fromJson(json['sales'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'owner': owner,
      'description': description,
      'location': location,
      'visibility': visibility.name,
      'date': date.toString(),
      'categories':
          categories.map((e) => e.fold((l) => l, (r) => r.toJson())).toList(),
      'ticketTypes':
          ticketTypes.map((e) => e.fold((l) => l, (r) => r.toJson())).toList(),
      'createdBy': createdBy.fold((l) => l, (r) => r.toJson()),
      'createdAt': createdAt.toString(),
      'views': views,
      'clicks': clicks,
      'shares': shares,
      'bookmarks': bookmarks,
      'lastUpdated': lastUpdated.toString(),
      'mediaUrls': mediaUrls,
      'sales': sales?.toJson(),
    };
  }

  Event copyWith({
    ObjectId? id,
    String? name,
    String? owner,
    String? description,
    String? location,
    Visibility? visibility,
    DateTime? date,
    List<Either<ObjectId, EventCategory>>? categories,
    List<Either<ObjectId, TicketType>>? ticketTypes,
    Either<ObjectId, User>? createdBy,
    DateTime? createdAt,
    int? views,
    int? clicks,
    int? shares,
    int? bookmarks,
    DateTime? lastUpdated,
    List<String>? mediaUrls,
    EventSales? sales,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      location: location ?? this.location,
      visibility: visibility ?? this.visibility,
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
      sales: sales ?? this.sales,
    );
  }

  factory Event.sampleData() {
    return Event(
      id: ObjectId(),
      name: 'Karaoke 🎙️',
      owner: 'John Doe',
      description: 'Sing your heart out!',
      location: 'Karaoke Bar',
      date: DateTime.now(),
      categories: [
        Right(EventCategory.sampleData().copyWith(id: ObjectId())),
      ],
      ticketTypes: [
        Right(
          TicketType.sampleData().copyWith(id: ObjectId()),
        ),
      ],
      createdBy: Right(User.sampleData().copyWith($_id: ObjectId())),
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      mediaUrls: [
        'https://picsum.photos/200',
      ],
    );
  }
}

class EventRequest {
  final String name;
  final String owner;
  final String description;
  final String location;
  final Visibility visibility;
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
    required this.visibility,
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
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.public,
      ),
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
      'visibility': visibility.name,
      'date': date.toString(),
      'categories': categories,
      'ticketTypes': ticketTypes,
      'createdBy': createdBy,
      'createdAt': createdAt.toString(),
    };
  }
}
