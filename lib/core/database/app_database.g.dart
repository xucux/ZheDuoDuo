// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DealsTable extends Deals with TableInfo<$DealsTable, Deal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('其他'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('其他'),
  );
  static const VerificationMeta _currentPriceMeta = const VerificationMeta(
    'currentPrice',
  );
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
    'current_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPriceMeta = const VerificationMeta(
    'originalPrice',
  );
  @override
  late final GeneratedColumn<double> originalPrice = GeneratedColumn<double>(
    'original_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayPriceMeta = const VerificationMeta(
    'displayPrice',
  );
  @override
  late final GeneratedColumn<double> displayPrice = GeneratedColumn<double>(
    'display_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('¥'),
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<String> discount = GeneratedColumn<String>(
    'discount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logisticsMeta = const VerificationMeta(
    'logistics',
  );
  @override
  late final GeneratedColumn<String> logistics = GeneratedColumn<String>(
    'logistics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visualTypeMeta = const VerificationMeta(
    'visualType',
  );
  @override
  late final GeneratedColumn<String> visualType = GeneratedColumn<String>(
    'visual_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _asciiArtMeta = const VerificationMeta(
    'asciiArt',
  );
  @override
  late final GeneratedColumn<String> asciiArt = GeneratedColumn<String>(
    'ascii_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salesJsonMeta = const VerificationMeta(
    'salesJson',
  );
  @override
  late final GeneratedColumn<String> salesJson = GeneratedColumn<String>(
    'sales_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLowestPriceMeta = const VerificationMeta(
    'isLowestPrice',
  );
  @override
  late final GeneratedColumn<int> isLowestPrice = GeneratedColumn<int>(
    'is_lowest_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    platform,
    category,
    currentPrice,
    originalPrice,
    displayPrice,
    currency,
    discount,
    logistics,
    link,
    note,
    visualType,
    asciiArt,
    salesJson,
    isLowestPrice,
    createdAt,
    updatedAt,
    revision,
    deleted,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('current_price')) {
      context.handle(
        _currentPriceMeta,
        currentPrice.isAcceptableOrUnknown(
          data['current_price']!,
          _currentPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentPriceMeta);
    }
    if (data.containsKey('original_price')) {
      context.handle(
        _originalPriceMeta,
        originalPrice.isAcceptableOrUnknown(
          data['original_price']!,
          _originalPriceMeta,
        ),
      );
    }
    if (data.containsKey('display_price')) {
      context.handle(
        _displayPriceMeta,
        displayPrice.isAcceptableOrUnknown(
          data['display_price']!,
          _displayPriceMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('logistics')) {
      context.handle(
        _logisticsMeta,
        logistics.isAcceptableOrUnknown(data['logistics']!, _logisticsMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('visual_type')) {
      context.handle(
        _visualTypeMeta,
        visualType.isAcceptableOrUnknown(data['visual_type']!, _visualTypeMeta),
      );
    }
    if (data.containsKey('ascii_art')) {
      context.handle(
        _asciiArtMeta,
        asciiArt.isAcceptableOrUnknown(data['ascii_art']!, _asciiArtMeta),
      );
    }
    if (data.containsKey('sales_json')) {
      context.handle(
        _salesJsonMeta,
        salesJson.isAcceptableOrUnknown(data['sales_json']!, _salesJsonMeta),
      );
    }
    if (data.containsKey('is_lowest_price')) {
      context.handle(
        _isLowestPriceMeta,
        isLowestPrice.isAcceptableOrUnknown(
          data['is_lowest_price']!,
          _isLowestPriceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      currentPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_price'],
      )!,
      originalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_price'],
      ),
      displayPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}display_price'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount'],
      ),
      logistics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logistics'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      visualType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visual_type'],
      )!,
      asciiArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ascii_art'],
      ),
      salesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_json'],
      ),
      isLowestPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_lowest_price'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $DealsTable createAlias(String alias) {
    return $DealsTable(attachedDatabase, alias);
  }
}

class Deal extends DataClass implements Insertable<Deal> {
  final String id;
  final String title;
  final String platform;
  final String category;
  final double currentPrice;
  final double? originalPrice;
  final double? displayPrice;
  final String currency;
  final String? discount;
  final String? logistics;
  final String? link;
  final String? note;
  final String visualType;
  final String? asciiArt;
  final String? salesJson;
  final int isLowestPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int revision;
  final int deleted;
  final DateTime? deletedAt;
  final String? deviceId;
  const Deal({
    required this.id,
    required this.title,
    required this.platform,
    required this.category,
    required this.currentPrice,
    this.originalPrice,
    this.displayPrice,
    required this.currency,
    this.discount,
    this.logistics,
    this.link,
    this.note,
    required this.visualType,
    this.asciiArt,
    this.salesJson,
    required this.isLowestPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    required this.deleted,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['platform'] = Variable<String>(platform);
    map['category'] = Variable<String>(category);
    map['current_price'] = Variable<double>(currentPrice);
    if (!nullToAbsent || originalPrice != null) {
      map['original_price'] = Variable<double>(originalPrice);
    }
    if (!nullToAbsent || displayPrice != null) {
      map['display_price'] = Variable<double>(displayPrice);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || discount != null) {
      map['discount'] = Variable<String>(discount);
    }
    if (!nullToAbsent || logistics != null) {
      map['logistics'] = Variable<String>(logistics);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['visual_type'] = Variable<String>(visualType);
    if (!nullToAbsent || asciiArt != null) {
      map['ascii_art'] = Variable<String>(asciiArt);
    }
    if (!nullToAbsent || salesJson != null) {
      map['sales_json'] = Variable<String>(salesJson);
    }
    map['is_lowest_price'] = Variable<int>(isLowestPrice);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    map['deleted'] = Variable<int>(deleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  DealsCompanion toCompanion(bool nullToAbsent) {
    return DealsCompanion(
      id: Value(id),
      title: Value(title),
      platform: Value(platform),
      category: Value(category),
      currentPrice: Value(currentPrice),
      originalPrice: originalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(originalPrice),
      displayPrice: displayPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(displayPrice),
      currency: Value(currency),
      discount: discount == null && nullToAbsent
          ? const Value.absent()
          : Value(discount),
      logistics: logistics == null && nullToAbsent
          ? const Value.absent()
          : Value(logistics),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      visualType: Value(visualType),
      asciiArt: asciiArt == null && nullToAbsent
          ? const Value.absent()
          : Value(asciiArt),
      salesJson: salesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(salesJson),
      isLowestPrice: Value(isLowestPrice),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      deleted: Value(deleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Deal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deal(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      platform: serializer.fromJson<String>(json['platform']),
      category: serializer.fromJson<String>(json['category']),
      currentPrice: serializer.fromJson<double>(json['currentPrice']),
      originalPrice: serializer.fromJson<double?>(json['originalPrice']),
      displayPrice: serializer.fromJson<double?>(json['displayPrice']),
      currency: serializer.fromJson<String>(json['currency']),
      discount: serializer.fromJson<String?>(json['discount']),
      logistics: serializer.fromJson<String?>(json['logistics']),
      link: serializer.fromJson<String?>(json['link']),
      note: serializer.fromJson<String?>(json['note']),
      visualType: serializer.fromJson<String>(json['visualType']),
      asciiArt: serializer.fromJson<String?>(json['asciiArt']),
      salesJson: serializer.fromJson<String?>(json['salesJson']),
      isLowestPrice: serializer.fromJson<int>(json['isLowestPrice']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      deleted: serializer.fromJson<int>(json['deleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'platform': serializer.toJson<String>(platform),
      'category': serializer.toJson<String>(category),
      'currentPrice': serializer.toJson<double>(currentPrice),
      'originalPrice': serializer.toJson<double?>(originalPrice),
      'displayPrice': serializer.toJson<double?>(displayPrice),
      'currency': serializer.toJson<String>(currency),
      'discount': serializer.toJson<String?>(discount),
      'logistics': serializer.toJson<String?>(logistics),
      'link': serializer.toJson<String?>(link),
      'note': serializer.toJson<String?>(note),
      'visualType': serializer.toJson<String>(visualType),
      'asciiArt': serializer.toJson<String?>(asciiArt),
      'salesJson': serializer.toJson<String?>(salesJson),
      'isLowestPrice': serializer.toJson<int>(isLowestPrice),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'deleted': serializer.toJson<int>(deleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Deal copyWith({
    String? id,
    String? title,
    String? platform,
    String? category,
    double? currentPrice,
    Value<double?> originalPrice = const Value.absent(),
    Value<double?> displayPrice = const Value.absent(),
    String? currency,
    Value<String?> discount = const Value.absent(),
    Value<String?> logistics = const Value.absent(),
    Value<String?> link = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? visualType,
    Value<String?> asciiArt = const Value.absent(),
    Value<String?> salesJson = const Value.absent(),
    int? isLowestPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revision,
    int? deleted,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => Deal(
    id: id ?? this.id,
    title: title ?? this.title,
    platform: platform ?? this.platform,
    category: category ?? this.category,
    currentPrice: currentPrice ?? this.currentPrice,
    originalPrice: originalPrice.present
        ? originalPrice.value
        : this.originalPrice,
    displayPrice: displayPrice.present ? displayPrice.value : this.displayPrice,
    currency: currency ?? this.currency,
    discount: discount.present ? discount.value : this.discount,
    logistics: logistics.present ? logistics.value : this.logistics,
    link: link.present ? link.value : this.link,
    note: note.present ? note.value : this.note,
    visualType: visualType ?? this.visualType,
    asciiArt: asciiArt.present ? asciiArt.value : this.asciiArt,
    salesJson: salesJson.present ? salesJson.value : this.salesJson,
    isLowestPrice: isLowestPrice ?? this.isLowestPrice,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
    deleted: deleted ?? this.deleted,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  Deal copyWithCompanion(DealsCompanion data) {
    return Deal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      platform: data.platform.present ? data.platform.value : this.platform,
      category: data.category.present ? data.category.value : this.category,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      originalPrice: data.originalPrice.present
          ? data.originalPrice.value
          : this.originalPrice,
      displayPrice: data.displayPrice.present
          ? data.displayPrice.value
          : this.displayPrice,
      currency: data.currency.present ? data.currency.value : this.currency,
      discount: data.discount.present ? data.discount.value : this.discount,
      logistics: data.logistics.present ? data.logistics.value : this.logistics,
      link: data.link.present ? data.link.value : this.link,
      note: data.note.present ? data.note.value : this.note,
      visualType: data.visualType.present
          ? data.visualType.value
          : this.visualType,
      asciiArt: data.asciiArt.present ? data.asciiArt.value : this.asciiArt,
      salesJson: data.salesJson.present ? data.salesJson.value : this.salesJson,
      isLowestPrice: data.isLowestPrice.present
          ? data.isLowestPrice.value
          : this.isLowestPrice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('platform: $platform, ')
          ..write('category: $category, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('displayPrice: $displayPrice, ')
          ..write('currency: $currency, ')
          ..write('discount: $discount, ')
          ..write('logistics: $logistics, ')
          ..write('link: $link, ')
          ..write('note: $note, ')
          ..write('visualType: $visualType, ')
          ..write('asciiArt: $asciiArt, ')
          ..write('salesJson: $salesJson, ')
          ..write('isLowestPrice: $isLowestPrice, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('deleted: $deleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    platform,
    category,
    currentPrice,
    originalPrice,
    displayPrice,
    currency,
    discount,
    logistics,
    link,
    note,
    visualType,
    asciiArt,
    salesJson,
    isLowestPrice,
    createdAt,
    updatedAt,
    revision,
    deleted,
    deletedAt,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deal &&
          other.id == this.id &&
          other.title == this.title &&
          other.platform == this.platform &&
          other.category == this.category &&
          other.currentPrice == this.currentPrice &&
          other.originalPrice == this.originalPrice &&
          other.displayPrice == this.displayPrice &&
          other.currency == this.currency &&
          other.discount == this.discount &&
          other.logistics == this.logistics &&
          other.link == this.link &&
          other.note == this.note &&
          other.visualType == this.visualType &&
          other.asciiArt == this.asciiArt &&
          other.salesJson == this.salesJson &&
          other.isLowestPrice == this.isLowestPrice &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.deleted == this.deleted &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class DealsCompanion extends UpdateCompanion<Deal> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> platform;
  final Value<String> category;
  final Value<double> currentPrice;
  final Value<double?> originalPrice;
  final Value<double?> displayPrice;
  final Value<String> currency;
  final Value<String?> discount;
  final Value<String?> logistics;
  final Value<String?> link;
  final Value<String?> note;
  final Value<String> visualType;
  final Value<String?> asciiArt;
  final Value<String?> salesJson;
  final Value<int> isLowestPrice;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<int> deleted;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const DealsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.platform = const Value.absent(),
    this.category = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.originalPrice = const Value.absent(),
    this.displayPrice = const Value.absent(),
    this.currency = const Value.absent(),
    this.discount = const Value.absent(),
    this.logistics = const Value.absent(),
    this.link = const Value.absent(),
    this.note = const Value.absent(),
    this.visualType = const Value.absent(),
    this.asciiArt = const Value.absent(),
    this.salesJson = const Value.absent(),
    this.isLowestPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealsCompanion.insert({
    required String id,
    required String title,
    this.platform = const Value.absent(),
    this.category = const Value.absent(),
    required double currentPrice,
    this.originalPrice = const Value.absent(),
    this.displayPrice = const Value.absent(),
    this.currency = const Value.absent(),
    this.discount = const Value.absent(),
    this.logistics = const Value.absent(),
    this.link = const Value.absent(),
    this.note = const Value.absent(),
    this.visualType = const Value.absent(),
    this.asciiArt = const Value.absent(),
    this.salesJson = const Value.absent(),
    this.isLowestPrice = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       currentPrice = Value(currentPrice),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Deal> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? platform,
    Expression<String>? category,
    Expression<double>? currentPrice,
    Expression<double>? originalPrice,
    Expression<double>? displayPrice,
    Expression<String>? currency,
    Expression<String>? discount,
    Expression<String>? logistics,
    Expression<String>? link,
    Expression<String>? note,
    Expression<String>? visualType,
    Expression<String>? asciiArt,
    Expression<String>? salesJson,
    Expression<int>? isLowestPrice,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<int>? deleted,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (platform != null) 'platform': platform,
      if (category != null) 'category': category,
      if (currentPrice != null) 'current_price': currentPrice,
      if (originalPrice != null) 'original_price': originalPrice,
      if (displayPrice != null) 'display_price': displayPrice,
      if (currency != null) 'currency': currency,
      if (discount != null) 'discount': discount,
      if (logistics != null) 'logistics': logistics,
      if (link != null) 'link': link,
      if (note != null) 'note': note,
      if (visualType != null) 'visual_type': visualType,
      if (asciiArt != null) 'ascii_art': asciiArt,
      if (salesJson != null) 'sales_json': salesJson,
      if (isLowestPrice != null) 'is_lowest_price': isLowestPrice,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (deleted != null) 'deleted': deleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? platform,
    Value<String>? category,
    Value<double>? currentPrice,
    Value<double?>? originalPrice,
    Value<double?>? displayPrice,
    Value<String>? currency,
    Value<String?>? discount,
    Value<String?>? logistics,
    Value<String?>? link,
    Value<String?>? note,
    Value<String>? visualType,
    Value<String?>? asciiArt,
    Value<String?>? salesJson,
    Value<int>? isLowestPrice,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<int>? deleted,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return DealsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      category: category ?? this.category,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      displayPrice: displayPrice ?? this.displayPrice,
      currency: currency ?? this.currency,
      discount: discount ?? this.discount,
      logistics: logistics ?? this.logistics,
      link: link ?? this.link,
      note: note ?? this.note,
      visualType: visualType ?? this.visualType,
      asciiArt: asciiArt ?? this.asciiArt,
      salesJson: salesJson ?? this.salesJson,
      isLowestPrice: isLowestPrice ?? this.isLowestPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (originalPrice.present) {
      map['original_price'] = Variable<double>(originalPrice.value);
    }
    if (displayPrice.present) {
      map['display_price'] = Variable<double>(displayPrice.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (discount.present) {
      map['discount'] = Variable<String>(discount.value);
    }
    if (logistics.present) {
      map['logistics'] = Variable<String>(logistics.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (visualType.present) {
      map['visual_type'] = Variable<String>(visualType.value);
    }
    if (asciiArt.present) {
      map['ascii_art'] = Variable<String>(asciiArt.value);
    }
    if (salesJson.present) {
      map['sales_json'] = Variable<String>(salesJson.value);
    }
    if (isLowestPrice.present) {
      map['is_lowest_price'] = Variable<int>(isLowestPrice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('platform: $platform, ')
          ..write('category: $category, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('originalPrice: $originalPrice, ')
          ..write('displayPrice: $displayPrice, ')
          ..write('currency: $currency, ')
          ..write('discount: $discount, ')
          ..write('logistics: $logistics, ')
          ..write('link: $link, ')
          ..write('note: $note, ')
          ..write('visualType: $visualType, ')
          ..write('asciiArt: $asciiArt, ')
          ..write('salesJson: $salesJson, ')
          ..write('isLowestPrice: $isLowestPrice, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('deleted: $deleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealTagsTable extends DealTags with TableInfo<$DealTagsTable, DealTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dealId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deal_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dealId, tag};
  @override
  DealTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealTag(
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $DealTagsTable createAlias(String alias) {
    return $DealTagsTable(attachedDatabase, alias);
  }
}

class DealTag extends DataClass implements Insertable<DealTag> {
  final String dealId;
  final String tag;
  const DealTag({required this.dealId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deal_id'] = Variable<String>(dealId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  DealTagsCompanion toCompanion(bool nullToAbsent) {
    return DealTagsCompanion(dealId: Value(dealId), tag: Value(tag));
  }

  factory DealTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealTag(
      dealId: serializer.fromJson<String>(json['dealId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dealId': serializer.toJson<String>(dealId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  DealTag copyWith({String? dealId, String? tag}) =>
      DealTag(dealId: dealId ?? this.dealId, tag: tag ?? this.tag);
  DealTag copyWithCompanion(DealTagsCompanion data) {
    return DealTag(
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealTag(')
          ..write('dealId: $dealId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dealId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealTag &&
          other.dealId == this.dealId &&
          other.tag == this.tag);
}

class DealTagsCompanion extends UpdateCompanion<DealTag> {
  final Value<String> dealId;
  final Value<String> tag;
  final Value<int> rowid;
  const DealTagsCompanion({
    this.dealId = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealTagsCompanion.insert({
    required String dealId,
    required String tag,
    this.rowid = const Value.absent(),
  }) : dealId = Value(dealId),
       tag = Value(tag);
  static Insertable<DealTag> custom({
    Expression<String>? dealId,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dealId != null) 'deal_id': dealId,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealTagsCompanion copyWith({
    Value<String>? dealId,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return DealTagsCompanion(
      dealId: dealId ?? this.dealId,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealTagsCompanion(')
          ..write('dealId: $dealId, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealPromotionsTable extends DealPromotions
    with TableInfo<$DealPromotionsTable, DealPromotion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealPromotionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dealId, sortOrder, textContent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deal_promotions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealPromotion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dealId, sortOrder};
  @override
  DealPromotion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealPromotion(
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
    );
  }

  @override
  $DealPromotionsTable createAlias(String alias) {
    return $DealPromotionsTable(attachedDatabase, alias);
  }
}

class DealPromotion extends DataClass implements Insertable<DealPromotion> {
  final String dealId;
  final int sortOrder;
  final String textContent;
  const DealPromotion({
    required this.dealId,
    required this.sortOrder,
    required this.textContent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deal_id'] = Variable<String>(dealId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['text_content'] = Variable<String>(textContent);
    return map;
  }

  DealPromotionsCompanion toCompanion(bool nullToAbsent) {
    return DealPromotionsCompanion(
      dealId: Value(dealId),
      sortOrder: Value(sortOrder),
      textContent: Value(textContent),
    );
  }

  factory DealPromotion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealPromotion(
      dealId: serializer.fromJson<String>(json['dealId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      textContent: serializer.fromJson<String>(json['textContent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dealId': serializer.toJson<String>(dealId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'textContent': serializer.toJson<String>(textContent),
    };
  }

  DealPromotion copyWith({
    String? dealId,
    int? sortOrder,
    String? textContent,
  }) => DealPromotion(
    dealId: dealId ?? this.dealId,
    sortOrder: sortOrder ?? this.sortOrder,
    textContent: textContent ?? this.textContent,
  );
  DealPromotion copyWithCompanion(DealPromotionsCompanion data) {
    return DealPromotion(
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealPromotion(')
          ..write('dealId: $dealId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('textContent: $textContent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dealId, sortOrder, textContent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealPromotion &&
          other.dealId == this.dealId &&
          other.sortOrder == this.sortOrder &&
          other.textContent == this.textContent);
}

class DealPromotionsCompanion extends UpdateCompanion<DealPromotion> {
  final Value<String> dealId;
  final Value<int> sortOrder;
  final Value<String> textContent;
  final Value<int> rowid;
  const DealPromotionsCompanion({
    this.dealId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.textContent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealPromotionsCompanion.insert({
    required String dealId,
    required int sortOrder,
    required String textContent,
    this.rowid = const Value.absent(),
  }) : dealId = Value(dealId),
       sortOrder = Value(sortOrder),
       textContent = Value(textContent);
  static Insertable<DealPromotion> custom({
    Expression<String>? dealId,
    Expression<int>? sortOrder,
    Expression<String>? textContent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dealId != null) 'deal_id': dealId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (textContent != null) 'text_content': textContent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealPromotionsCompanion copyWith({
    Value<String>? dealId,
    Value<int>? sortOrder,
    Value<String>? textContent,
    Value<int>? rowid,
  }) {
    return DealPromotionsCompanion(
      dealId: dealId ?? this.dealId,
      sortOrder: sortOrder ?? this.sortOrder,
      textContent: textContent ?? this.textContent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealPromotionsCompanion(')
          ..write('dealId: $dealId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('textContent: $textContent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CouponsTable extends Coupons with TableInfo<$CouponsTable, Coupon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CouponsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dealId,
    sortOrder,
    count,
    source,
    strength,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coupons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Coupon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Coupon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Coupon(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CouponsTable createAlias(String alias) {
    return $CouponsTable(attachedDatabase, alias);
  }
}

class Coupon extends DataClass implements Insertable<Coupon> {
  final int id;
  final String dealId;
  final int sortOrder;
  final int count;
  final String source;
  final String strength;
  final String? note;
  const Coupon({
    required this.id,
    required this.dealId,
    required this.sortOrder,
    required this.count,
    required this.source,
    required this.strength,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deal_id'] = Variable<String>(dealId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['count'] = Variable<int>(count);
    map['source'] = Variable<String>(source);
    map['strength'] = Variable<String>(strength);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CouponsCompanion toCompanion(bool nullToAbsent) {
    return CouponsCompanion(
      id: Value(id),
      dealId: Value(dealId),
      sortOrder: Value(sortOrder),
      count: Value(count),
      source: Value(source),
      strength: Value(strength),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Coupon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Coupon(
      id: serializer.fromJson<int>(json['id']),
      dealId: serializer.fromJson<String>(json['dealId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      count: serializer.fromJson<int>(json['count']),
      source: serializer.fromJson<String>(json['source']),
      strength: serializer.fromJson<String>(json['strength']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dealId': serializer.toJson<String>(dealId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'count': serializer.toJson<int>(count),
      'source': serializer.toJson<String>(source),
      'strength': serializer.toJson<String>(strength),
      'note': serializer.toJson<String?>(note),
    };
  }

  Coupon copyWith({
    int? id,
    String? dealId,
    int? sortOrder,
    int? count,
    String? source,
    String? strength,
    Value<String?> note = const Value.absent(),
  }) => Coupon(
    id: id ?? this.id,
    dealId: dealId ?? this.dealId,
    sortOrder: sortOrder ?? this.sortOrder,
    count: count ?? this.count,
    source: source ?? this.source,
    strength: strength ?? this.strength,
    note: note.present ? note.value : this.note,
  );
  Coupon copyWithCompanion(CouponsCompanion data) {
    return Coupon(
      id: data.id.present ? data.id.value : this.id,
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      count: data.count.present ? data.count.value : this.count,
      source: data.source.present ? data.source.value : this.source,
      strength: data.strength.present ? data.strength.value : this.strength,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Coupon(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('count: $count, ')
          ..write('source: $source, ')
          ..write('strength: $strength, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dealId, sortOrder, count, source, strength, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Coupon &&
          other.id == this.id &&
          other.dealId == this.dealId &&
          other.sortOrder == this.sortOrder &&
          other.count == this.count &&
          other.source == this.source &&
          other.strength == this.strength &&
          other.note == this.note);
}

class CouponsCompanion extends UpdateCompanion<Coupon> {
  final Value<int> id;
  final Value<String> dealId;
  final Value<int> sortOrder;
  final Value<int> count;
  final Value<String> source;
  final Value<String> strength;
  final Value<String?> note;
  const CouponsCompanion({
    this.id = const Value.absent(),
    this.dealId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.count = const Value.absent(),
    this.source = const Value.absent(),
    this.strength = const Value.absent(),
    this.note = const Value.absent(),
  });
  CouponsCompanion.insert({
    this.id = const Value.absent(),
    required String dealId,
    this.sortOrder = const Value.absent(),
    this.count = const Value.absent(),
    this.source = const Value.absent(),
    this.strength = const Value.absent(),
    this.note = const Value.absent(),
  }) : dealId = Value(dealId);
  static Insertable<Coupon> custom({
    Expression<int>? id,
    Expression<String>? dealId,
    Expression<int>? sortOrder,
    Expression<int>? count,
    Expression<String>? source,
    Expression<String>? strength,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dealId != null) 'deal_id': dealId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (count != null) 'count': count,
      if (source != null) 'source': source,
      if (strength != null) 'strength': strength,
      if (note != null) 'note': note,
    });
  }

  CouponsCompanion copyWith({
    Value<int>? id,
    Value<String>? dealId,
    Value<int>? sortOrder,
    Value<int>? count,
    Value<String>? source,
    Value<String>? strength,
    Value<String?>? note,
  }) {
    return CouponsCompanion(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      sortOrder: sortOrder ?? this.sortOrder,
      count: count ?? this.count,
      source: source ?? this.source,
      strength: strength ?? this.strength,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CouponsCompanion(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('count: $count, ')
          ..write('source: $source, ')
          ..write('strength: $strength, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $DealImagesTable extends DealImages
    with TableInfo<$DealImagesTable, DealImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSizeMeta = const VerificationMeta(
    'originalSize',
  );
  @override
  late final GeneratedColumn<int> originalSize = GeneratedColumn<int>(
    'original_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compressedSizeMeta = const VerificationMeta(
    'compressedSize',
  );
  @override
  late final GeneratedColumn<int> compressedSize = GeneratedColumn<int>(
    'compressed_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dealId,
    imagePath,
    thumbPath,
    width,
    height,
    quality,
    originalSize,
    compressedSize,
    sourceUrl,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deal_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('original_size')) {
      context.handle(
        _originalSizeMeta,
        originalSize.isAcceptableOrUnknown(
          data['original_size']!,
          _originalSizeMeta,
        ),
      );
    }
    if (data.containsKey('compressed_size')) {
      context.handle(
        _compressedSizeMeta,
        compressedSize.isAcceptableOrUnknown(
          data['compressed_size']!,
          _compressedSizeMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dealId};
  @override
  DealImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealImage(
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      ),
      originalSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_size'],
      ),
      compressedSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compressed_size'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $DealImagesTable createAlias(String alias) {
    return $DealImagesTable(attachedDatabase, alias);
  }
}

class DealImage extends DataClass implements Insertable<DealImage> {
  final String dealId;
  final String imagePath;
  final String? thumbPath;
  final int? width;
  final int? height;
  final int? quality;
  final int? originalSize;
  final int? compressedSize;
  final String? sourceUrl;
  final DateTime updatedAt;
  final int deleted;
  const DealImage({
    required this.dealId,
    required this.imagePath,
    this.thumbPath,
    this.width,
    this.height,
    this.quality,
    this.originalSize,
    this.compressedSize,
    this.sourceUrl,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deal_id'] = Variable<String>(dealId);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    if (!nullToAbsent || originalSize != null) {
      map['original_size'] = Variable<int>(originalSize);
    }
    if (!nullToAbsent || compressedSize != null) {
      map['compressed_size'] = Variable<int>(compressedSize);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  DealImagesCompanion toCompanion(bool nullToAbsent) {
    return DealImagesCompanion(
      dealId: Value(dealId),
      imagePath: Value(imagePath),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      originalSize: originalSize == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSize),
      compressedSize: compressedSize == null && nullToAbsent
          ? const Value.absent()
          : Value(compressedSize),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory DealImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealImage(
      dealId: serializer.fromJson<String>(json['dealId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      quality: serializer.fromJson<int?>(json['quality']),
      originalSize: serializer.fromJson<int?>(json['originalSize']),
      compressedSize: serializer.fromJson<int?>(json['compressedSize']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dealId': serializer.toJson<String>(dealId),
      'imagePath': serializer.toJson<String>(imagePath),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'quality': serializer.toJson<int?>(quality),
      'originalSize': serializer.toJson<int?>(originalSize),
      'compressedSize': serializer.toJson<int?>(compressedSize),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  DealImage copyWith({
    String? dealId,
    String? imagePath,
    Value<String?> thumbPath = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> quality = const Value.absent(),
    Value<int?> originalSize = const Value.absent(),
    Value<int?> compressedSize = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    DateTime? updatedAt,
    int? deleted,
  }) => DealImage(
    dealId: dealId ?? this.dealId,
    imagePath: imagePath ?? this.imagePath,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    quality: quality.present ? quality.value : this.quality,
    originalSize: originalSize.present ? originalSize.value : this.originalSize,
    compressedSize: compressedSize.present
        ? compressedSize.value
        : this.compressedSize,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  DealImage copyWithCompanion(DealImagesCompanion data) {
    return DealImage(
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      quality: data.quality.present ? data.quality.value : this.quality,
      originalSize: data.originalSize.present
          ? data.originalSize.value
          : this.originalSize,
      compressedSize: data.compressedSize.present
          ? data.compressedSize.value
          : this.compressedSize,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealImage(')
          ..write('dealId: $dealId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('quality: $quality, ')
          ..write('originalSize: $originalSize, ')
          ..write('compressedSize: $compressedSize, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    dealId,
    imagePath,
    thumbPath,
    width,
    height,
    quality,
    originalSize,
    compressedSize,
    sourceUrl,
    updatedAt,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealImage &&
          other.dealId == this.dealId &&
          other.imagePath == this.imagePath &&
          other.thumbPath == this.thumbPath &&
          other.width == this.width &&
          other.height == this.height &&
          other.quality == this.quality &&
          other.originalSize == this.originalSize &&
          other.compressedSize == this.compressedSize &&
          other.sourceUrl == this.sourceUrl &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class DealImagesCompanion extends UpdateCompanion<DealImage> {
  final Value<String> dealId;
  final Value<String> imagePath;
  final Value<String?> thumbPath;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> quality;
  final Value<int?> originalSize;
  final Value<int?> compressedSize;
  final Value<String?> sourceUrl;
  final Value<DateTime> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const DealImagesCompanion({
    this.dealId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.quality = const Value.absent(),
    this.originalSize = const Value.absent(),
    this.compressedSize = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealImagesCompanion.insert({
    required String dealId,
    required String imagePath,
    this.thumbPath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.quality = const Value.absent(),
    this.originalSize = const Value.absent(),
    this.compressedSize = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dealId = Value(dealId),
       imagePath = Value(imagePath),
       updatedAt = Value(updatedAt);
  static Insertable<DealImage> custom({
    Expression<String>? dealId,
    Expression<String>? imagePath,
    Expression<String>? thumbPath,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? quality,
    Expression<int>? originalSize,
    Expression<int>? compressedSize,
    Expression<String>? sourceUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dealId != null) 'deal_id': dealId,
      if (imagePath != null) 'image_path': imagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (quality != null) 'quality': quality,
      if (originalSize != null) 'original_size': originalSize,
      if (compressedSize != null) 'compressed_size': compressedSize,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealImagesCompanion copyWith({
    Value<String>? dealId,
    Value<String>? imagePath,
    Value<String?>? thumbPath,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? quality,
    Value<int?>? originalSize,
    Value<int?>? compressedSize,
    Value<String?>? sourceUrl,
    Value<DateTime>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return DealImagesCompanion(
      dealId: dealId ?? this.dealId,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      width: width ?? this.width,
      height: height ?? this.height,
      quality: quality ?? this.quality,
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize ?? this.compressedSize,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (originalSize.present) {
      map['original_size'] = Variable<int>(originalSize.value);
    }
    if (compressedSize.present) {
      map['compressed_size'] = Variable<int>(compressedSize.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealImagesCompanion(')
          ..write('dealId: $dealId, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('quality: $quality, ')
          ..write('originalSize: $originalSize, ')
          ..write('compressedSize: $compressedSize, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPushAt = GeneratedColumn<DateTime>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    localRevision,
    lastPushAt,
    lastPullAt,
    remoteRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final int id;
  final String deviceId;
  final int localRevision;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;
  final int remoteRevision;
  const SyncMetaData({
    required this.id,
    required this.deviceId,
    required this.localRevision,
    this.lastPushAt,
    this.lastPullAt,
    required this.remoteRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['local_revision'] = Variable<int>(localRevision);
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    map['remote_revision'] = Variable<int>(remoteRevision);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      localRevision: Value(localRevision),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      remoteRevision: Value(remoteRevision),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      lastPushAt: serializer.fromJson<DateTime?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
      remoteRevision: serializer.fromJson<int>(json['remoteRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'localRevision': serializer.toJson<int>(localRevision),
      'lastPushAt': serializer.toJson<DateTime?>(lastPushAt),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
      'remoteRevision': serializer.toJson<int>(remoteRevision),
    };
  }

  SyncMetaData copyWith({
    int? id,
    String? deviceId,
    int? localRevision,
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
    int? remoteRevision,
  }) => SyncMetaData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    localRevision: localRevision ?? this.localRevision,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    remoteRevision: remoteRevision ?? this.remoteRevision,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('localRevision: $localRevision, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('remoteRevision: $remoteRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    localRevision,
    lastPushAt,
    lastPullAt,
    remoteRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.localRevision == this.localRevision &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt &&
          other.remoteRevision == this.remoteRevision);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> localRevision;
  final Value<DateTime?> lastPushAt;
  final Value<DateTime?> lastPullAt;
  final Value<int> remoteRevision;
  const SyncMetaCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.remoteRevision = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.localRevision = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.remoteRevision = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncMetaData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? localRevision,
    Expression<DateTime>? lastPushAt,
    Expression<DateTime>? lastPullAt,
    Expression<int>? remoteRevision,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (localRevision != null) 'local_revision': localRevision,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
    });
  }

  SyncMetaCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? localRevision,
    Value<DateTime?>? lastPushAt,
    Value<DateTime?>? lastPullAt,
    Value<int>? remoteRevision,
  }) {
    return SyncMetaCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      localRevision: localRevision ?? this.localRevision,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      remoteRevision: remoteRevision ?? this.remoteRevision,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('localRevision: $localRevision, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('remoteRevision: $remoteRevision')
          ..write(')'))
        .toString();
  }
}

class $SyncChangelogTable extends SyncChangelog
    with TableInfo<$SyncChangelogTable, SyncChangelogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangelogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadHashMeta = const VerificationMeta(
    'payloadHash',
  );
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
    'payload_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    entityType,
    entityId,
    operation,
    revision,
    changedAt,
    syncedAt,
    payloadHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_changelog';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChangelogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
        _payloadHashMeta,
        payloadHash.isAcceptableOrUnknown(
          data['payload_hash']!,
          _payloadHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncChangelogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChangelogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      payloadHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_hash'],
      ),
    );
  }

  @override
  $SyncChangelogTable createAlias(String alias) {
    return $SyncChangelogTable(attachedDatabase, alias);
  }
}

class SyncChangelogData extends DataClass
    implements Insertable<SyncChangelogData> {
  final int id;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operation;
  final int revision;
  final DateTime changedAt;
  final DateTime? syncedAt;
  final String? payloadHash;
  const SyncChangelogData({
    required this.id,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.revision,
    required this.changedAt,
    this.syncedAt,
    this.payloadHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['revision'] = Variable<int>(revision);
    map['changed_at'] = Variable<DateTime>(changedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || payloadHash != null) {
      map['payload_hash'] = Variable<String>(payloadHash);
    }
    return map;
  }

  SyncChangelogCompanion toCompanion(bool nullToAbsent) {
    return SyncChangelogCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      revision: Value(revision),
      changedAt: Value(changedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      payloadHash: payloadHash == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadHash),
    );
  }

  factory SyncChangelogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChangelogData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      revision: serializer.fromJson<int>(json['revision']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      payloadHash: serializer.fromJson<String?>(json['payloadHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'revision': serializer.toJson<int>(revision),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'payloadHash': serializer.toJson<String?>(payloadHash),
    };
  }

  SyncChangelogData copyWith({
    int? id,
    String? deviceId,
    String? entityType,
    String? entityId,
    String? operation,
    int? revision,
    DateTime? changedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
    Value<String?> payloadHash = const Value.absent(),
  }) => SyncChangelogData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    revision: revision ?? this.revision,
    changedAt: changedAt ?? this.changedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    payloadHash: payloadHash.present ? payloadHash.value : this.payloadHash,
  );
  SyncChangelogData copyWithCompanion(SyncChangelogCompanion data) {
    return SyncChangelogData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      revision: data.revision.present ? data.revision.value : this.revision,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      payloadHash: data.payloadHash.present
          ? data.payloadHash.value
          : this.payloadHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangelogData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('revision: $revision, ')
          ..write('changedAt: $changedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('payloadHash: $payloadHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    entityType,
    entityId,
    operation,
    revision,
    changedAt,
    syncedAt,
    payloadHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChangelogData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.revision == this.revision &&
          other.changedAt == this.changedAt &&
          other.syncedAt == this.syncedAt &&
          other.payloadHash == this.payloadHash);
}

class SyncChangelogCompanion extends UpdateCompanion<SyncChangelogData> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<int> revision;
  final Value<DateTime> changedAt;
  final Value<DateTime?> syncedAt;
  final Value<String?> payloadHash;
  const SyncChangelogCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.revision = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.payloadHash = const Value.absent(),
  });
  SyncChangelogCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operation,
    required int revision,
    required DateTime changedAt,
    this.syncedAt = const Value.absent(),
    this.payloadHash = const Value.absent(),
  }) : deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       revision = Value(revision),
       changedAt = Value(changedAt);
  static Insertable<SyncChangelogData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<int>? revision,
    Expression<DateTime>? changedAt,
    Expression<DateTime>? syncedAt,
    Expression<String>? payloadHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (revision != null) 'revision': revision,
      if (changedAt != null) 'changed_at': changedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (payloadHash != null) 'payload_hash': payloadHash,
    });
  }

  SyncChangelogCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<int>? revision,
    Value<DateTime>? changedAt,
    Value<DateTime?>? syncedAt,
    Value<String?>? payloadHash,
  }) {
    return SyncChangelogCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      revision: revision ?? this.revision,
      changedAt: changedAt ?? this.changedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      payloadHash: payloadHash ?? this.payloadHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangelogCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('revision: $revision, ')
          ..write('changedAt: $changedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('payloadHash: $payloadHash')
          ..write(')'))
        .toString();
  }
}

class $BackupRecordsTable extends BackupRecords
    with TableInfo<$BackupRecordsTable, BackupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dealCountMeta = const VerificationMeta(
    'dealCount',
  );
  @override
  late final GeneratedColumn<int> dealCount = GeneratedColumn<int>(
    'deal_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    fileSize,
    dealCount,
    createdAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('deal_count')) {
      context.handle(
        _dealCountMeta,
        dealCount.isAcceptableOrUnknown(data['deal_count']!, _dealCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      dealCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deal_count'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $BackupRecordsTable createAlias(String alias) {
    return $BackupRecordsTable(attachedDatabase, alias);
  }
}

class BackupRecord extends DataClass implements Insertable<BackupRecord> {
  final int id;
  final String filePath;
  final int? fileSize;
  final int? dealCount;
  final DateTime createdAt;
  final String source;
  const BackupRecord({
    required this.id,
    required this.filePath,
    this.fileSize,
    this.dealCount,
    required this.createdAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || dealCount != null) {
      map['deal_count'] = Variable<int>(dealCount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  BackupRecordsCompanion toCompanion(bool nullToAbsent) {
    return BackupRecordsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      dealCount: dealCount == null && nullToAbsent
          ? const Value.absent()
          : Value(dealCount),
      createdAt: Value(createdAt),
      source: Value(source),
    );
  }

  factory BackupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRecord(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      dealCount: serializer.fromJson<int?>(json['dealCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'fileSize': serializer.toJson<int?>(fileSize),
      'dealCount': serializer.toJson<int?>(dealCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'source': serializer.toJson<String>(source),
    };
  }

  BackupRecord copyWith({
    int? id,
    String? filePath,
    Value<int?> fileSize = const Value.absent(),
    Value<int?> dealCount = const Value.absent(),
    DateTime? createdAt,
    String? source,
  }) => BackupRecord(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    dealCount: dealCount.present ? dealCount.value : this.dealCount,
    createdAt: createdAt ?? this.createdAt,
    source: source ?? this.source,
  );
  BackupRecord copyWithCompanion(BackupRecordsCompanion data) {
    return BackupRecord(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      dealCount: data.dealCount.present ? data.dealCount.value : this.dealCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecord(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('dealCount: $dealCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, filePath, fileSize, dealCount, createdAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRecord &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.fileSize == this.fileSize &&
          other.dealCount == this.dealCount &&
          other.createdAt == this.createdAt &&
          other.source == this.source);
}

class BackupRecordsCompanion extends UpdateCompanion<BackupRecord> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<int?> fileSize;
  final Value<int?> dealCount;
  final Value<DateTime> createdAt;
  final Value<String> source;
  const BackupRecordsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.dealCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.source = const Value.absent(),
  });
  BackupRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.fileSize = const Value.absent(),
    this.dealCount = const Value.absent(),
    required DateTime createdAt,
    this.source = const Value.absent(),
  }) : filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<BackupRecord> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<int>? fileSize,
    Expression<int>? dealCount,
    Expression<DateTime>? createdAt,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (fileSize != null) 'file_size': fileSize,
      if (dealCount != null) 'deal_count': dealCount,
      if (createdAt != null) 'created_at': createdAt,
      if (source != null) 'source': source,
    });
  }

  BackupRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<int?>? fileSize,
    Value<int?>? dealCount,
    Value<DateTime>? createdAt,
    Value<String>? source,
  }) {
    return BackupRecordsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      dealCount: dealCount ?? this.dealCount,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (dealCount.present) {
      map['deal_count'] = Variable<int>(dealCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('dealCount: $dealCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $AiConfigsTable extends AiConfigs
    with TableInfo<$AiConfigsTable, AiConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerPresetMeta = const VerificationMeta(
    'providerPreset',
  );
  @override
  late final GeneratedColumn<String> providerPreset = GeneratedColumn<String>(
    'provider_preset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('openaiChat'),
  );
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _agentRoleMeta = const VerificationMeta(
    'agentRole',
  );
  @override
  late final GeneratedColumn<String> agentRole = GeneratedColumn<String>(
    'agent_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _agentPromptMeta = const VerificationMeta(
    'agentPrompt',
  );
  @override
  late final GeneratedColumn<String> agentPrompt = GeneratedColumn<String>(
    'agent_prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.7),
  );
  static const VerificationMeta _maxTokensMeta = const VerificationMeta(
    'maxTokens',
  );
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
    'max_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4096),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerPreset,
    protocol,
    apiKey,
    baseUrl,
    model,
    agentRole,
    agentPrompt,
    temperature,
    maxTokens,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_preset')) {
      context.handle(
        _providerPresetMeta,
        providerPreset.isAcceptableOrUnknown(
          data['provider_preset']!,
          _providerPresetMeta,
        ),
      );
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('agent_role')) {
      context.handle(
        _agentRoleMeta,
        agentRole.isAcceptableOrUnknown(data['agent_role']!, _agentRoleMeta),
      );
    }
    if (data.containsKey('agent_prompt')) {
      context.handle(
        _agentPromptMeta,
        agentPrompt.isAcceptableOrUnknown(
          data['agent_prompt']!,
          _agentPromptMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('max_tokens')) {
      context.handle(
        _maxTokensMeta,
        maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_preset'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      agentRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_role'],
      )!,
      agentPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_prompt'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      maxTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_tokens'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiConfigsTable createAlias(String alias) {
    return $AiConfigsTable(attachedDatabase, alias);
  }
}

class AiConfig extends DataClass implements Insertable<AiConfig> {
  /// 配置唯一标识
  final String id;

  /// 服务商预设 ID（deepseek / siliconflow / openai / claude / custom）
  final String providerPreset;

  /// 协议类型（openaiResponses / openaiChat / anthropic / githubCopilot）
  final String protocol;

  /// API Key（明文存储）
  final String apiKey;

  /// Base URL
  final String baseUrl;

  /// 模型名称
  final String model;

  /// Agent 角色 ID（default / shopping / yaml_parser）
  final String agentRole;

  /// Agent 系统提示词
  final String agentPrompt;

  /// 温度参数（0.0 - 2.0）
  final double temperature;

  /// 最大输出 token 数
  final int maxTokens;

  /// 是否为当前激活的配置
  final int isActive;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const AiConfig({
    required this.id,
    required this.providerPreset,
    required this.protocol,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.agentRole,
    required this.agentPrompt,
    required this.temperature,
    required this.maxTokens,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_preset'] = Variable<String>(providerPreset);
    map['protocol'] = Variable<String>(protocol);
    map['api_key'] = Variable<String>(apiKey);
    map['base_url'] = Variable<String>(baseUrl);
    map['model'] = Variable<String>(model);
    map['agent_role'] = Variable<String>(agentRole);
    map['agent_prompt'] = Variable<String>(agentPrompt);
    map['temperature'] = Variable<double>(temperature);
    map['max_tokens'] = Variable<int>(maxTokens);
    map['is_active'] = Variable<int>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiConfigsCompanion toCompanion(bool nullToAbsent) {
    return AiConfigsCompanion(
      id: Value(id),
      providerPreset: Value(providerPreset),
      protocol: Value(protocol),
      apiKey: Value(apiKey),
      baseUrl: Value(baseUrl),
      model: Value(model),
      agentRole: Value(agentRole),
      agentPrompt: Value(agentPrompt),
      temperature: Value(temperature),
      maxTokens: Value(maxTokens),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiConfig(
      id: serializer.fromJson<String>(json['id']),
      providerPreset: serializer.fromJson<String>(json['providerPreset']),
      protocol: serializer.fromJson<String>(json['protocol']),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      model: serializer.fromJson<String>(json['model']),
      agentRole: serializer.fromJson<String>(json['agentRole']),
      agentPrompt: serializer.fromJson<String>(json['agentPrompt']),
      temperature: serializer.fromJson<double>(json['temperature']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      isActive: serializer.fromJson<int>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerPreset': serializer.toJson<String>(providerPreset),
      'protocol': serializer.toJson<String>(protocol),
      'apiKey': serializer.toJson<String>(apiKey),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'model': serializer.toJson<String>(model),
      'agentRole': serializer.toJson<String>(agentRole),
      'agentPrompt': serializer.toJson<String>(agentPrompt),
      'temperature': serializer.toJson<double>(temperature),
      'maxTokens': serializer.toJson<int>(maxTokens),
      'isActive': serializer.toJson<int>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiConfig copyWith({
    String? id,
    String? providerPreset,
    String? protocol,
    String? apiKey,
    String? baseUrl,
    String? model,
    String? agentRole,
    String? agentPrompt,
    double? temperature,
    int? maxTokens,
    int? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AiConfig(
    id: id ?? this.id,
    providerPreset: providerPreset ?? this.providerPreset,
    protocol: protocol ?? this.protocol,
    apiKey: apiKey ?? this.apiKey,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    agentRole: agentRole ?? this.agentRole,
    agentPrompt: agentPrompt ?? this.agentPrompt,
    temperature: temperature ?? this.temperature,
    maxTokens: maxTokens ?? this.maxTokens,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiConfig copyWithCompanion(AiConfigsCompanion data) {
    return AiConfig(
      id: data.id.present ? data.id.value : this.id,
      providerPreset: data.providerPreset.present
          ? data.providerPreset.value
          : this.providerPreset,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      model: data.model.present ? data.model.value : this.model,
      agentRole: data.agentRole.present ? data.agentRole.value : this.agentRole,
      agentPrompt: data.agentPrompt.present
          ? data.agentPrompt.value
          : this.agentPrompt,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiConfig(')
          ..write('id: $id, ')
          ..write('providerPreset: $providerPreset, ')
          ..write('protocol: $protocol, ')
          ..write('apiKey: $apiKey, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('model: $model, ')
          ..write('agentRole: $agentRole, ')
          ..write('agentPrompt: $agentPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerPreset,
    protocol,
    apiKey,
    baseUrl,
    model,
    agentRole,
    agentPrompt,
    temperature,
    maxTokens,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiConfig &&
          other.id == this.id &&
          other.providerPreset == this.providerPreset &&
          other.protocol == this.protocol &&
          other.apiKey == this.apiKey &&
          other.baseUrl == this.baseUrl &&
          other.model == this.model &&
          other.agentRole == this.agentRole &&
          other.agentPrompt == this.agentPrompt &&
          other.temperature == this.temperature &&
          other.maxTokens == this.maxTokens &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiConfigsCompanion extends UpdateCompanion<AiConfig> {
  final Value<String> id;
  final Value<String> providerPreset;
  final Value<String> protocol;
  final Value<String> apiKey;
  final Value<String> baseUrl;
  final Value<String> model;
  final Value<String> agentRole;
  final Value<String> agentPrompt;
  final Value<double> temperature;
  final Value<int> maxTokens;
  final Value<int> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiConfigsCompanion({
    this.id = const Value.absent(),
    this.providerPreset = const Value.absent(),
    this.protocol = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.model = const Value.absent(),
    this.agentRole = const Value.absent(),
    this.agentPrompt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiConfigsCompanion.insert({
    required String id,
    this.providerPreset = const Value.absent(),
    this.protocol = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.model = const Value.absent(),
    this.agentRole = const Value.absent(),
    this.agentPrompt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AiConfig> custom({
    Expression<String>? id,
    Expression<String>? providerPreset,
    Expression<String>? protocol,
    Expression<String>? apiKey,
    Expression<String>? baseUrl,
    Expression<String>? model,
    Expression<String>? agentRole,
    Expression<String>? agentPrompt,
    Expression<double>? temperature,
    Expression<int>? maxTokens,
    Expression<int>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerPreset != null) 'provider_preset': providerPreset,
      if (protocol != null) 'protocol': protocol,
      if (apiKey != null) 'api_key': apiKey,
      if (baseUrl != null) 'base_url': baseUrl,
      if (model != null) 'model': model,
      if (agentRole != null) 'agent_role': agentRole,
      if (agentPrompt != null) 'agent_prompt': agentPrompt,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerPreset,
    Value<String>? protocol,
    Value<String>? apiKey,
    Value<String>? baseUrl,
    Value<String>? model,
    Value<String>? agentRole,
    Value<String>? agentPrompt,
    Value<double>? temperature,
    Value<int>? maxTokens,
    Value<int>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiConfigsCompanion(
      id: id ?? this.id,
      providerPreset: providerPreset ?? this.providerPreset,
      protocol: protocol ?? this.protocol,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      agentRole: agentRole ?? this.agentRole,
      agentPrompt: agentPrompt ?? this.agentPrompt,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerPreset.present) {
      map['provider_preset'] = Variable<String>(providerPreset.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (agentRole.present) {
      map['agent_role'] = Variable<String>(agentRole.value);
    }
    if (agentPrompt.present) {
      map['agent_prompt'] = Variable<String>(agentPrompt.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiConfigsCompanion(')
          ..write('id: $id, ')
          ..write('providerPreset: $providerPreset, ')
          ..write('protocol: $protocol, ')
          ..write('apiKey: $apiKey, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('model: $model, ')
          ..write('agentRole: $agentRole, ')
          ..write('agentPrompt: $agentPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SecretsTable extends Secrets with TableInfo<$SecretsTable, Secret> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecretsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyNameMeta = const VerificationMeta(
    'keyName',
  );
  @override
  late final GeneratedColumn<String> keyName = GeneratedColumn<String>(
    'key_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyValueMeta = const VerificationMeta(
    'keyValue',
  );
  @override
  late final GeneratedColumn<String> keyValue = GeneratedColumn<String>(
    'key_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    keyName,
    keyValue,
    entityId,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'secrets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Secret> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('key_name')) {
      context.handle(
        _keyNameMeta,
        keyName.isAcceptableOrUnknown(data['key_name']!, _keyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_keyNameMeta);
    }
    if (data.containsKey('key_value')) {
      context.handle(
        _keyValueMeta,
        keyValue.isAcceptableOrUnknown(data['key_value']!, _keyValueMeta),
      );
    } else if (isInserting) {
      context.missing(_keyValueMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Secret map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Secret(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      keyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_name'],
      )!,
      keyValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_value'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SecretsTable createAlias(String alias) {
    return $SecretsTable(attachedDatabase, alias);
  }
}

class Secret extends DataClass implements Insertable<Secret> {
  /// 自增主键
  final int id;

  /// 凭证类别（ai / webdav / cos / oss / other）
  final String category;

  /// 凭证键名（如 api_key / password / access_key / secret_key）
  final String keyName;

  /// 凭证值（明文存储）
  final String keyValue;

  /// 关联实体 ID（如 AI 配置 ID、WebDAV 配置名等，可选）
  final String? entityId;

  /// 备注
  final String? note;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const Secret({
    required this.id,
    required this.category,
    required this.keyName,
    required this.keyValue,
    this.entityId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['key_name'] = Variable<String>(keyName);
    map['key_value'] = Variable<String>(keyValue);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SecretsCompanion toCompanion(bool nullToAbsent) {
    return SecretsCompanion(
      id: Value(id),
      category: Value(category),
      keyName: Value(keyName),
      keyValue: Value(keyValue),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Secret.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Secret(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      keyName: serializer.fromJson<String>(json['keyName']),
      keyValue: serializer.fromJson<String>(json['keyValue']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'keyName': serializer.toJson<String>(keyName),
      'keyValue': serializer.toJson<String>(keyValue),
      'entityId': serializer.toJson<String?>(entityId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Secret copyWith({
    int? id,
    String? category,
    String? keyName,
    String? keyValue,
    Value<String?> entityId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Secret(
    id: id ?? this.id,
    category: category ?? this.category,
    keyName: keyName ?? this.keyName,
    keyValue: keyValue ?? this.keyValue,
    entityId: entityId.present ? entityId.value : this.entityId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Secret copyWithCompanion(SecretsCompanion data) {
    return Secret(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      keyName: data.keyName.present ? data.keyName.value : this.keyName,
      keyValue: data.keyValue.present ? data.keyValue.value : this.keyValue,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Secret(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('keyName: $keyName, ')
          ..write('keyValue: $keyValue, ')
          ..write('entityId: $entityId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    keyName,
    keyValue,
    entityId,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Secret &&
          other.id == this.id &&
          other.category == this.category &&
          other.keyName == this.keyName &&
          other.keyValue == this.keyValue &&
          other.entityId == this.entityId &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SecretsCompanion extends UpdateCompanion<Secret> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> keyName;
  final Value<String> keyValue;
  final Value<String?> entityId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SecretsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.keyName = const Value.absent(),
    this.keyValue = const Value.absent(),
    this.entityId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SecretsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String keyName,
    required String keyValue,
    this.entityId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : category = Value(category),
       keyName = Value(keyName),
       keyValue = Value(keyValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Secret> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? keyName,
    Expression<String>? keyValue,
    Expression<String>? entityId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (keyName != null) 'key_name': keyName,
      if (keyValue != null) 'key_value': keyValue,
      if (entityId != null) 'entity_id': entityId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SecretsCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? keyName,
    Value<String>? keyValue,
    Value<String?>? entityId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SecretsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      keyName: keyName ?? this.keyName,
      keyValue: keyValue ?? this.keyValue,
      entityId: entityId ?? this.entityId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (keyName.present) {
      map['key_name'] = Variable<String>(keyName.value);
    }
    if (keyValue.present) {
      map['key_value'] = Variable<String>(keyValue.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecretsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('keyName: $keyName, ')
          ..write('keyValue: $keyValue, ')
          ..write('entityId: $entityId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PromptsTable extends Prompts with TableInfo<$PromptsTable, Prompt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    content,
    category,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prompt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Prompt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prompt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PromptsTable createAlias(String alias) {
    return $PromptsTable(attachedDatabase, alias);
  }
}

class Prompt extends DataClass implements Insertable<Prompt> {
  final String id;
  final String name;
  final String content;
  final String category;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Prompt({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    map['category'] = Variable<String>(category);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptsCompanion toCompanion(bool nullToAbsent) {
    return PromptsCompanion(
      id: Value(id),
      name: Value(name),
      content: Value(content),
      category: Value(category),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Prompt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prompt(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<String>(json['category']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<String>(category),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Prompt copyWith({
    String? id,
    String? name,
    String? content,
    String? category,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Prompt(
    id: id ?? this.id,
    name: name ?? this.name,
    content: content ?? this.content,
    category: category ?? this.category,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Prompt copyWithCompanion(PromptsCompanion data) {
    return Prompt(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prompt(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, content, category, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prompt &&
          other.id == this.id &&
          other.name == this.name &&
          other.content == this.content &&
          other.category == this.category &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PromptsCompanion extends UpdateCompanion<Prompt> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> content;
  final Value<String> category;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PromptsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptsCompanion.insert({
    required String id,
    required String name,
    required String content,
    this.category = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Prompt> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? category,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? content,
    Value<String>? category,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PromptsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageCompressSettingsTable extends ImageCompressSettings
    with TableInfo<$ImageCompressSettingsTable, ImageCompressSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCompressSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _minSizeMeta = const VerificationMeta(
    'minSize',
  );
  @override
  late final GeneratedColumn<int> minSize = GeneratedColumn<int>(
    'min_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxWidthMeta = const VerificationMeta(
    'maxWidth',
  );
  @override
  late final GeneratedColumn<int> maxWidth = GeneratedColumn<int>(
    'max_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1600),
  );
  @override
  List<GeneratedColumn> get $columns => [minSize, quality, label, maxWidth];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_compress_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCompressSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('min_size')) {
      context.handle(
        _minSizeMeta,
        minSize.isAcceptableOrUnknown(data['min_size']!, _minSizeMeta),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('max_width')) {
      context.handle(
        _maxWidthMeta,
        maxWidth.isAcceptableOrUnknown(data['max_width']!, _maxWidthMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {minSize};
  @override
  ImageCompressSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCompressSetting(
      minSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_size'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      maxWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_width'],
      )!,
    );
  }

  @override
  $ImageCompressSettingsTable createAlias(String alias) {
    return $ImageCompressSettingsTable(attachedDatabase, alias);
  }
}

class ImageCompressSetting extends DataClass
    implements Insertable<ImageCompressSetting> {
  /// 文件大小阈值（字节），作为主键
  final int minSize;

  /// 压缩质量（0-100），数值越低压缩率越高
  final int quality;

  /// 档位显示名称
  final String label;

  /// 最大宽度（像素），超过此宽度会等比缩放，0 表示不限制
  final int maxWidth;
  const ImageCompressSetting({
    required this.minSize,
    required this.quality,
    required this.label,
    required this.maxWidth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['min_size'] = Variable<int>(minSize);
    map['quality'] = Variable<int>(quality);
    map['label'] = Variable<String>(label);
    map['max_width'] = Variable<int>(maxWidth);
    return map;
  }

  ImageCompressSettingsCompanion toCompanion(bool nullToAbsent) {
    return ImageCompressSettingsCompanion(
      minSize: Value(minSize),
      quality: Value(quality),
      label: Value(label),
      maxWidth: Value(maxWidth),
    );
  }

  factory ImageCompressSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCompressSetting(
      minSize: serializer.fromJson<int>(json['minSize']),
      quality: serializer.fromJson<int>(json['quality']),
      label: serializer.fromJson<String>(json['label']),
      maxWidth: serializer.fromJson<int>(json['maxWidth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'minSize': serializer.toJson<int>(minSize),
      'quality': serializer.toJson<int>(quality),
      'label': serializer.toJson<String>(label),
      'maxWidth': serializer.toJson<int>(maxWidth),
    };
  }

  ImageCompressSetting copyWith({
    int? minSize,
    int? quality,
    String? label,
    int? maxWidth,
  }) => ImageCompressSetting(
    minSize: minSize ?? this.minSize,
    quality: quality ?? this.quality,
    label: label ?? this.label,
    maxWidth: maxWidth ?? this.maxWidth,
  );
  ImageCompressSetting copyWithCompanion(ImageCompressSettingsCompanion data) {
    return ImageCompressSetting(
      minSize: data.minSize.present ? data.minSize.value : this.minSize,
      quality: data.quality.present ? data.quality.value : this.quality,
      label: data.label.present ? data.label.value : this.label,
      maxWidth: data.maxWidth.present ? data.maxWidth.value : this.maxWidth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCompressSetting(')
          ..write('minSize: $minSize, ')
          ..write('quality: $quality, ')
          ..write('label: $label, ')
          ..write('maxWidth: $maxWidth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(minSize, quality, label, maxWidth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCompressSetting &&
          other.minSize == this.minSize &&
          other.quality == this.quality &&
          other.label == this.label &&
          other.maxWidth == this.maxWidth);
}

class ImageCompressSettingsCompanion
    extends UpdateCompanion<ImageCompressSetting> {
  final Value<int> minSize;
  final Value<int> quality;
  final Value<String> label;
  final Value<int> maxWidth;
  const ImageCompressSettingsCompanion({
    this.minSize = const Value.absent(),
    this.quality = const Value.absent(),
    this.label = const Value.absent(),
    this.maxWidth = const Value.absent(),
  });
  ImageCompressSettingsCompanion.insert({
    this.minSize = const Value.absent(),
    required int quality,
    required String label,
    this.maxWidth = const Value.absent(),
  }) : quality = Value(quality),
       label = Value(label);
  static Insertable<ImageCompressSetting> custom({
    Expression<int>? minSize,
    Expression<int>? quality,
    Expression<String>? label,
    Expression<int>? maxWidth,
  }) {
    return RawValuesInsertable({
      if (minSize != null) 'min_size': minSize,
      if (quality != null) 'quality': quality,
      if (label != null) 'label': label,
      if (maxWidth != null) 'max_width': maxWidth,
    });
  }

  ImageCompressSettingsCompanion copyWith({
    Value<int>? minSize,
    Value<int>? quality,
    Value<String>? label,
    Value<int>? maxWidth,
  }) {
    return ImageCompressSettingsCompanion(
      minSize: minSize ?? this.minSize,
      quality: quality ?? this.quality,
      label: label ?? this.label,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (minSize.present) {
      map['min_size'] = Variable<int>(minSize.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (maxWidth.present) {
      map['max_width'] = Variable<int>(maxWidth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCompressSettingsCompanion(')
          ..write('minSize: $minSize, ')
          ..write('quality: $quality, ')
          ..write('label: $label, ')
          ..write('maxWidth: $maxWidth')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DealsTable deals = $DealsTable(this);
  late final $DealTagsTable dealTags = $DealTagsTable(this);
  late final $DealPromotionsTable dealPromotions = $DealPromotionsTable(this);
  late final $CouponsTable coupons = $CouponsTable(this);
  late final $DealImagesTable dealImages = $DealImagesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $SyncChangelogTable syncChangelog = $SyncChangelogTable(this);
  late final $BackupRecordsTable backupRecords = $BackupRecordsTable(this);
  late final $AiConfigsTable aiConfigs = $AiConfigsTable(this);
  late final $SecretsTable secrets = $SecretsTable(this);
  late final $PromptsTable prompts = $PromptsTable(this);
  late final $ImageCompressSettingsTable imageCompressSettings =
      $ImageCompressSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    deals,
    dealTags,
    dealPromotions,
    coupons,
    dealImages,
    appSettings,
    syncMeta,
    syncChangelog,
    backupRecords,
    aiConfigs,
    secrets,
    prompts,
    imageCompressSettings,
  ];
}

typedef $$DealsTableCreateCompanionBuilder =
    DealsCompanion Function({
      required String id,
      required String title,
      Value<String> platform,
      Value<String> category,
      required double currentPrice,
      Value<double?> originalPrice,
      Value<double?> displayPrice,
      Value<String> currency,
      Value<String?> discount,
      Value<String?> logistics,
      Value<String?> link,
      Value<String?> note,
      Value<String> visualType,
      Value<String?> asciiArt,
      Value<String?> salesJson,
      Value<int> isLowestPrice,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> revision,
      Value<int> deleted,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$DealsTableUpdateCompanionBuilder =
    DealsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> platform,
      Value<String> category,
      Value<double> currentPrice,
      Value<double?> originalPrice,
      Value<double?> displayPrice,
      Value<String> currency,
      Value<String?> discount,
      Value<String?> logistics,
      Value<String?> link,
      Value<String?> note,
      Value<String> visualType,
      Value<String?> asciiArt,
      Value<String?> salesJson,
      Value<int> isLowestPrice,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<int> deleted,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$DealsTableFilterComposer extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get displayPrice => $composableBuilder(
    column: $table.displayPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logistics => $composableBuilder(
    column: $table.logistics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualType => $composableBuilder(
    column: $table.visualType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asciiArt => $composableBuilder(
    column: $table.asciiArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salesJson => $composableBuilder(
    column: $table.salesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isLowestPrice => $composableBuilder(
    column: $table.isLowestPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get displayPrice => $composableBuilder(
    column: $table.displayPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logistics => $composableBuilder(
    column: $table.logistics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualType => $composableBuilder(
    column: $table.visualType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asciiArt => $composableBuilder(
    column: $table.asciiArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salesJson => $composableBuilder(
    column: $table.salesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isLowestPrice => $composableBuilder(
    column: $table.isLowestPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalPrice => $composableBuilder(
    column: $table.originalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get displayPrice => $composableBuilder(
    column: $table.displayPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<String> get logistics =>
      $composableBuilder(column: $table.logistics, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get visualType => $composableBuilder(
    column: $table.visualType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asciiArt =>
      $composableBuilder(column: $table.asciiArt, builder: (column) => column);

  GeneratedColumn<String> get salesJson =>
      $composableBuilder(column: $table.salesJson, builder: (column) => column);

  GeneratedColumn<int> get isLowestPrice => $composableBuilder(
    column: $table.isLowestPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$DealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealsTable,
          Deal,
          $$DealsTableFilterComposer,
          $$DealsTableOrderingComposer,
          $$DealsTableAnnotationComposer,
          $$DealsTableCreateCompanionBuilder,
          $$DealsTableUpdateCompanionBuilder,
          (Deal, BaseReferences<_$AppDatabase, $DealsTable, Deal>),
          Deal,
          PrefetchHooks Function()
        > {
  $$DealsTableTableManager(_$AppDatabase db, $DealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> currentPrice = const Value.absent(),
                Value<double?> originalPrice = const Value.absent(),
                Value<double?> displayPrice = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> discount = const Value.absent(),
                Value<String?> logistics = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> visualType = const Value.absent(),
                Value<String?> asciiArt = const Value.absent(),
                Value<String?> salesJson = const Value.absent(),
                Value<int> isLowestPrice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion(
                id: id,
                title: title,
                platform: platform,
                category: category,
                currentPrice: currentPrice,
                originalPrice: originalPrice,
                displayPrice: displayPrice,
                currency: currency,
                discount: discount,
                logistics: logistics,
                link: link,
                note: note,
                visualType: visualType,
                asciiArt: asciiArt,
                salesJson: salesJson,
                isLowestPrice: isLowestPrice,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                deleted: deleted,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> platform = const Value.absent(),
                Value<String> category = const Value.absent(),
                required double currentPrice,
                Value<double?> originalPrice = const Value.absent(),
                Value<double?> displayPrice = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> discount = const Value.absent(),
                Value<String?> logistics = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> visualType = const Value.absent(),
                Value<String?> asciiArt = const Value.absent(),
                Value<String?> salesJson = const Value.absent(),
                Value<int> isLowestPrice = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion.insert(
                id: id,
                title: title,
                platform: platform,
                category: category,
                currentPrice: currentPrice,
                originalPrice: originalPrice,
                displayPrice: displayPrice,
                currency: currency,
                discount: discount,
                logistics: logistics,
                link: link,
                note: note,
                visualType: visualType,
                asciiArt: asciiArt,
                salesJson: salesJson,
                isLowestPrice: isLowestPrice,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                deleted: deleted,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealsTable,
      Deal,
      $$DealsTableFilterComposer,
      $$DealsTableOrderingComposer,
      $$DealsTableAnnotationComposer,
      $$DealsTableCreateCompanionBuilder,
      $$DealsTableUpdateCompanionBuilder,
      (Deal, BaseReferences<_$AppDatabase, $DealsTable, Deal>),
      Deal,
      PrefetchHooks Function()
    >;
typedef $$DealTagsTableCreateCompanionBuilder =
    DealTagsCompanion Function({
      required String dealId,
      required String tag,
      Value<int> rowid,
    });
typedef $$DealTagsTableUpdateCompanionBuilder =
    DealTagsCompanion Function({
      Value<String> dealId,
      Value<String> tag,
      Value<int> rowid,
    });

class $$DealTagsTableFilterComposer
    extends Composer<_$AppDatabase, $DealTagsTable> {
  $$DealTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealTagsTable> {
  $$DealTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealTagsTable> {
  $$DealTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$DealTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealTagsTable,
          DealTag,
          $$DealTagsTableFilterComposer,
          $$DealTagsTableOrderingComposer,
          $$DealTagsTableAnnotationComposer,
          $$DealTagsTableCreateCompanionBuilder,
          $$DealTagsTableUpdateCompanionBuilder,
          (DealTag, BaseReferences<_$AppDatabase, $DealTagsTable, DealTag>),
          DealTag,
          PrefetchHooks Function()
        > {
  $$DealTagsTableTableManager(_$AppDatabase db, $DealTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dealId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealTagsCompanion(dealId: dealId, tag: tag, rowid: rowid),
          createCompanionCallback:
              ({
                required String dealId,
                required String tag,
                Value<int> rowid = const Value.absent(),
              }) => DealTagsCompanion.insert(
                dealId: dealId,
                tag: tag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealTagsTable,
      DealTag,
      $$DealTagsTableFilterComposer,
      $$DealTagsTableOrderingComposer,
      $$DealTagsTableAnnotationComposer,
      $$DealTagsTableCreateCompanionBuilder,
      $$DealTagsTableUpdateCompanionBuilder,
      (DealTag, BaseReferences<_$AppDatabase, $DealTagsTable, DealTag>),
      DealTag,
      PrefetchHooks Function()
    >;
typedef $$DealPromotionsTableCreateCompanionBuilder =
    DealPromotionsCompanion Function({
      required String dealId,
      required int sortOrder,
      required String textContent,
      Value<int> rowid,
    });
typedef $$DealPromotionsTableUpdateCompanionBuilder =
    DealPromotionsCompanion Function({
      Value<String> dealId,
      Value<int> sortOrder,
      Value<String> textContent,
      Value<int> rowid,
    });

class $$DealPromotionsTableFilterComposer
    extends Composer<_$AppDatabase, $DealPromotionsTable> {
  $$DealPromotionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealPromotionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealPromotionsTable> {
  $$DealPromotionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealPromotionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealPromotionsTable> {
  $$DealPromotionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );
}

class $$DealPromotionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealPromotionsTable,
          DealPromotion,
          $$DealPromotionsTableFilterComposer,
          $$DealPromotionsTableOrderingComposer,
          $$DealPromotionsTableAnnotationComposer,
          $$DealPromotionsTableCreateCompanionBuilder,
          $$DealPromotionsTableUpdateCompanionBuilder,
          (
            DealPromotion,
            BaseReferences<_$AppDatabase, $DealPromotionsTable, DealPromotion>,
          ),
          DealPromotion,
          PrefetchHooks Function()
        > {
  $$DealPromotionsTableTableManager(
    _$AppDatabase db,
    $DealPromotionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealPromotionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealPromotionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealPromotionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dealId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealPromotionsCompanion(
                dealId: dealId,
                sortOrder: sortOrder,
                textContent: textContent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dealId,
                required int sortOrder,
                required String textContent,
                Value<int> rowid = const Value.absent(),
              }) => DealPromotionsCompanion.insert(
                dealId: dealId,
                sortOrder: sortOrder,
                textContent: textContent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealPromotionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealPromotionsTable,
      DealPromotion,
      $$DealPromotionsTableFilterComposer,
      $$DealPromotionsTableOrderingComposer,
      $$DealPromotionsTableAnnotationComposer,
      $$DealPromotionsTableCreateCompanionBuilder,
      $$DealPromotionsTableUpdateCompanionBuilder,
      (
        DealPromotion,
        BaseReferences<_$AppDatabase, $DealPromotionsTable, DealPromotion>,
      ),
      DealPromotion,
      PrefetchHooks Function()
    >;
typedef $$CouponsTableCreateCompanionBuilder =
    CouponsCompanion Function({
      Value<int> id,
      required String dealId,
      Value<int> sortOrder,
      Value<int> count,
      Value<String> source,
      Value<String> strength,
      Value<String?> note,
    });
typedef $$CouponsTableUpdateCompanionBuilder =
    CouponsCompanion Function({
      Value<int> id,
      Value<String> dealId,
      Value<int> sortOrder,
      Value<int> count,
      Value<String> source,
      Value<String> strength,
      Value<String?> note,
    });

class $$CouponsTableFilterComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CouponsTableOrderingComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CouponsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CouponsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CouponsTable,
          Coupon,
          $$CouponsTableFilterComposer,
          $$CouponsTableOrderingComposer,
          $$CouponsTableAnnotationComposer,
          $$CouponsTableCreateCompanionBuilder,
          $$CouponsTableUpdateCompanionBuilder,
          (Coupon, BaseReferences<_$AppDatabase, $CouponsTable, Coupon>),
          Coupon,
          PrefetchHooks Function()
        > {
  $$CouponsTableTableManager(_$AppDatabase db, $CouponsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CouponsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CouponsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CouponsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dealId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> strength = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CouponsCompanion(
                id: id,
                dealId: dealId,
                sortOrder: sortOrder,
                count: count,
                source: source,
                strength: strength,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dealId,
                Value<int> sortOrder = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> strength = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CouponsCompanion.insert(
                id: id,
                dealId: dealId,
                sortOrder: sortOrder,
                count: count,
                source: source,
                strength: strength,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CouponsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CouponsTable,
      Coupon,
      $$CouponsTableFilterComposer,
      $$CouponsTableOrderingComposer,
      $$CouponsTableAnnotationComposer,
      $$CouponsTableCreateCompanionBuilder,
      $$CouponsTableUpdateCompanionBuilder,
      (Coupon, BaseReferences<_$AppDatabase, $CouponsTable, Coupon>),
      Coupon,
      PrefetchHooks Function()
    >;
typedef $$DealImagesTableCreateCompanionBuilder =
    DealImagesCompanion Function({
      required String dealId,
      required String imagePath,
      Value<String?> thumbPath,
      Value<int?> width,
      Value<int?> height,
      Value<int?> quality,
      Value<int?> originalSize,
      Value<int?> compressedSize,
      Value<String?> sourceUrl,
      required DateTime updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$DealImagesTableUpdateCompanionBuilder =
    DealImagesCompanion Function({
      Value<String> dealId,
      Value<String> imagePath,
      Value<String?> thumbPath,
      Value<int?> width,
      Value<int?> height,
      Value<int?> quality,
      Value<int?> originalSize,
      Value<int?> compressedSize,
      Value<String?> sourceUrl,
      Value<DateTime> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

class $$DealImagesTableFilterComposer
    extends Composer<_$AppDatabase, $DealImagesTable> {
  $$DealImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get compressedSize => $composableBuilder(
    column: $table.compressedSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DealImagesTable> {
  $$DealImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get compressedSize => $composableBuilder(
    column: $table.compressedSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealImagesTable> {
  $$DealImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get compressedSize => $composableBuilder(
    column: $table.compressedSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$DealImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealImagesTable,
          DealImage,
          $$DealImagesTableFilterComposer,
          $$DealImagesTableOrderingComposer,
          $$DealImagesTableAnnotationComposer,
          $$DealImagesTableCreateCompanionBuilder,
          $$DealImagesTableUpdateCompanionBuilder,
          (
            DealImage,
            BaseReferences<_$AppDatabase, $DealImagesTable, DealImage>,
          ),
          DealImage,
          PrefetchHooks Function()
        > {
  $$DealImagesTableTableManager(_$AppDatabase db, $DealImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dealId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> quality = const Value.absent(),
                Value<int?> originalSize = const Value.absent(),
                Value<int?> compressedSize = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealImagesCompanion(
                dealId: dealId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                width: width,
                height: height,
                quality: quality,
                originalSize: originalSize,
                compressedSize: compressedSize,
                sourceUrl: sourceUrl,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dealId,
                required String imagePath,
                Value<String?> thumbPath = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> quality = const Value.absent(),
                Value<int?> originalSize = const Value.absent(),
                Value<int?> compressedSize = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                required DateTime updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealImagesCompanion.insert(
                dealId: dealId,
                imagePath: imagePath,
                thumbPath: thumbPath,
                width: width,
                height: height,
                quality: quality,
                originalSize: originalSize,
                compressedSize: compressedSize,
                sourceUrl: sourceUrl,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealImagesTable,
      DealImage,
      $$DealImagesTableFilterComposer,
      $$DealImagesTableOrderingComposer,
      $$DealImagesTableAnnotationComposer,
      $$DealImagesTableCreateCompanionBuilder,
      $$DealImagesTableUpdateCompanionBuilder,
      (DealImage, BaseReferences<_$AppDatabase, $DealImagesTable, DealImage>),
      DealImage,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      required String deviceId,
      Value<int> localRevision,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<int> remoteRevision,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> localRevision,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<int> remoteRevision,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
              }) => SyncMetaCompanion(
                id: id,
                deviceId: deviceId,
                localRevision: localRevision,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                remoteRevision: remoteRevision,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                Value<int> localRevision = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                id: id,
                deviceId: deviceId,
                localRevision: localRevision,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                remoteRevision: remoteRevision,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;
typedef $$SyncChangelogTableCreateCompanionBuilder =
    SyncChangelogCompanion Function({
      Value<int> id,
      required String deviceId,
      required String entityType,
      required String entityId,
      required String operation,
      required int revision,
      required DateTime changedAt,
      Value<DateTime?> syncedAt,
      Value<String?> payloadHash,
    });
typedef $$SyncChangelogTableUpdateCompanionBuilder =
    SyncChangelogCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<int> revision,
      Value<DateTime> changedAt,
      Value<DateTime?> syncedAt,
      Value<String?> payloadHash,
    });

class $$SyncChangelogTableFilterComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncChangelogTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncChangelogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => column,
  );
}

class $$SyncChangelogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncChangelogTable,
          SyncChangelogData,
          $$SyncChangelogTableFilterComposer,
          $$SyncChangelogTableOrderingComposer,
          $$SyncChangelogTableAnnotationComposer,
          $$SyncChangelogTableCreateCompanionBuilder,
          $$SyncChangelogTableUpdateCompanionBuilder,
          (
            SyncChangelogData,
            BaseReferences<
              _$AppDatabase,
              $SyncChangelogTable,
              SyncChangelogData
            >,
          ),
          SyncChangelogData,
          PrefetchHooks Function()
        > {
  $$SyncChangelogTableTableManager(_$AppDatabase db, $SyncChangelogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncChangelogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncChangelogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncChangelogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String?> payloadHash = const Value.absent(),
              }) => SyncChangelogCompanion(
                id: id,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                revision: revision,
                changedAt: changedAt,
                syncedAt: syncedAt,
                payloadHash: payloadHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String entityType,
                required String entityId,
                required String operation,
                required int revision,
                required DateTime changedAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String?> payloadHash = const Value.absent(),
              }) => SyncChangelogCompanion.insert(
                id: id,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                revision: revision,
                changedAt: changedAt,
                syncedAt: syncedAt,
                payloadHash: payloadHash,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncChangelogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncChangelogTable,
      SyncChangelogData,
      $$SyncChangelogTableFilterComposer,
      $$SyncChangelogTableOrderingComposer,
      $$SyncChangelogTableAnnotationComposer,
      $$SyncChangelogTableCreateCompanionBuilder,
      $$SyncChangelogTableUpdateCompanionBuilder,
      (
        SyncChangelogData,
        BaseReferences<_$AppDatabase, $SyncChangelogTable, SyncChangelogData>,
      ),
      SyncChangelogData,
      PrefetchHooks Function()
    >;
typedef $$BackupRecordsTableCreateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      required String filePath,
      Value<int?> fileSize,
      Value<int?> dealCount,
      required DateTime createdAt,
      Value<String> source,
    });
typedef $$BackupRecordsTableUpdateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<int?> fileSize,
      Value<int?> dealCount,
      Value<DateTime> createdAt,
      Value<String> source,
    });

class $$BackupRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dealCount => $composableBuilder(
    column: $table.dealCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dealCount => $composableBuilder(
    column: $table.dealCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get dealCount =>
      $composableBuilder(column: $table.dealCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$BackupRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupRecordsTable,
          BackupRecord,
          $$BackupRecordsTableFilterComposer,
          $$BackupRecordsTableOrderingComposer,
          $$BackupRecordsTableAnnotationComposer,
          $$BackupRecordsTableCreateCompanionBuilder,
          $$BackupRecordsTableUpdateCompanionBuilder,
          (
            BackupRecord,
            BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecord>,
          ),
          BackupRecord,
          PrefetchHooks Function()
        > {
  $$BackupRecordsTableTableManager(_$AppDatabase db, $BackupRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> dealCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => BackupRecordsCompanion(
                id: id,
                filePath: filePath,
                fileSize: fileSize,
                dealCount: dealCount,
                createdAt: createdAt,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                Value<int?> fileSize = const Value.absent(),
                Value<int?> dealCount = const Value.absent(),
                required DateTime createdAt,
                Value<String> source = const Value.absent(),
              }) => BackupRecordsCompanion.insert(
                id: id,
                filePath: filePath,
                fileSize: fileSize,
                dealCount: dealCount,
                createdAt: createdAt,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupRecordsTable,
      BackupRecord,
      $$BackupRecordsTableFilterComposer,
      $$BackupRecordsTableOrderingComposer,
      $$BackupRecordsTableAnnotationComposer,
      $$BackupRecordsTableCreateCompanionBuilder,
      $$BackupRecordsTableUpdateCompanionBuilder,
      (
        BackupRecord,
        BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecord>,
      ),
      BackupRecord,
      PrefetchHooks Function()
    >;
typedef $$AiConfigsTableCreateCompanionBuilder =
    AiConfigsCompanion Function({
      required String id,
      Value<String> providerPreset,
      Value<String> protocol,
      Value<String> apiKey,
      Value<String> baseUrl,
      Value<String> model,
      Value<String> agentRole,
      Value<String> agentPrompt,
      Value<double> temperature,
      Value<int> maxTokens,
      Value<int> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AiConfigsTableUpdateCompanionBuilder =
    AiConfigsCompanion Function({
      Value<String> id,
      Value<String> providerPreset,
      Value<String> protocol,
      Value<String> apiKey,
      Value<String> baseUrl,
      Value<String> model,
      Value<String> agentRole,
      Value<String> agentPrompt,
      Value<double> temperature,
      Value<int> maxTokens,
      Value<int> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AiConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $AiConfigsTable> {
  $$AiConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerPreset => $composableBuilder(
    column: $table.providerPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentRole => $composableBuilder(
    column: $table.agentRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentPrompt => $composableBuilder(
    column: $table.agentPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiConfigsTable> {
  $$AiConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerPreset => $composableBuilder(
    column: $table.providerPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentRole => $composableBuilder(
    column: $table.agentRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentPrompt => $composableBuilder(
    column: $table.agentPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiConfigsTable> {
  $$AiConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerPreset => $composableBuilder(
    column: $table.providerPreset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get agentRole =>
      $composableBuilder(column: $table.agentRole, builder: (column) => column);

  GeneratedColumn<String> get agentPrompt => $composableBuilder(
    column: $table.agentPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiConfigsTable,
          AiConfig,
          $$AiConfigsTableFilterComposer,
          $$AiConfigsTableOrderingComposer,
          $$AiConfigsTableAnnotationComposer,
          $$AiConfigsTableCreateCompanionBuilder,
          $$AiConfigsTableUpdateCompanionBuilder,
          (AiConfig, BaseReferences<_$AppDatabase, $AiConfigsTable, AiConfig>),
          AiConfig,
          PrefetchHooks Function()
        > {
  $$AiConfigsTableTableManager(_$AppDatabase db, $AiConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerPreset = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> apiKey = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> agentRole = const Value.absent(),
                Value<String> agentPrompt = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<int> maxTokens = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiConfigsCompanion(
                id: id,
                providerPreset: providerPreset,
                protocol: protocol,
                apiKey: apiKey,
                baseUrl: baseUrl,
                model: model,
                agentRole: agentRole,
                agentPrompt: agentPrompt,
                temperature: temperature,
                maxTokens: maxTokens,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> providerPreset = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> apiKey = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> agentRole = const Value.absent(),
                Value<String> agentPrompt = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<int> maxTokens = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiConfigsCompanion.insert(
                id: id,
                providerPreset: providerPreset,
                protocol: protocol,
                apiKey: apiKey,
                baseUrl: baseUrl,
                model: model,
                agentRole: agentRole,
                agentPrompt: agentPrompt,
                temperature: temperature,
                maxTokens: maxTokens,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiConfigsTable,
      AiConfig,
      $$AiConfigsTableFilterComposer,
      $$AiConfigsTableOrderingComposer,
      $$AiConfigsTableAnnotationComposer,
      $$AiConfigsTableCreateCompanionBuilder,
      $$AiConfigsTableUpdateCompanionBuilder,
      (AiConfig, BaseReferences<_$AppDatabase, $AiConfigsTable, AiConfig>),
      AiConfig,
      PrefetchHooks Function()
    >;
typedef $$SecretsTableCreateCompanionBuilder =
    SecretsCompanion Function({
      Value<int> id,
      required String category,
      required String keyName,
      required String keyValue,
      Value<String?> entityId,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$SecretsTableUpdateCompanionBuilder =
    SecretsCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> keyName,
      Value<String> keyValue,
      Value<String?> entityId,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$SecretsTableFilterComposer
    extends Composer<_$AppDatabase, $SecretsTable> {
  $$SecretsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyName => $composableBuilder(
    column: $table.keyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyValue => $composableBuilder(
    column: $table.keyValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecretsTableOrderingComposer
    extends Composer<_$AppDatabase, $SecretsTable> {
  $$SecretsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyName => $composableBuilder(
    column: $table.keyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyValue => $composableBuilder(
    column: $table.keyValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecretsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecretsTable> {
  $$SecretsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get keyName =>
      $composableBuilder(column: $table.keyName, builder: (column) => column);

  GeneratedColumn<String> get keyValue =>
      $composableBuilder(column: $table.keyValue, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SecretsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecretsTable,
          Secret,
          $$SecretsTableFilterComposer,
          $$SecretsTableOrderingComposer,
          $$SecretsTableAnnotationComposer,
          $$SecretsTableCreateCompanionBuilder,
          $$SecretsTableUpdateCompanionBuilder,
          (Secret, BaseReferences<_$AppDatabase, $SecretsTable, Secret>),
          Secret,
          PrefetchHooks Function()
        > {
  $$SecretsTableTableManager(_$AppDatabase db, $SecretsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecretsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecretsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecretsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> keyName = const Value.absent(),
                Value<String> keyValue = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SecretsCompanion(
                id: id,
                category: category,
                keyName: keyName,
                keyValue: keyValue,
                entityId: entityId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String keyName,
                required String keyValue,
                Value<String?> entityId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => SecretsCompanion.insert(
                id: id,
                category: category,
                keyName: keyName,
                keyValue: keyValue,
                entityId: entityId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecretsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecretsTable,
      Secret,
      $$SecretsTableFilterComposer,
      $$SecretsTableOrderingComposer,
      $$SecretsTableAnnotationComposer,
      $$SecretsTableCreateCompanionBuilder,
      $$SecretsTableUpdateCompanionBuilder,
      (Secret, BaseReferences<_$AppDatabase, $SecretsTable, Secret>),
      Secret,
      PrefetchHooks Function()
    >;
typedef $$PromptsTableCreateCompanionBuilder =
    PromptsCompanion Function({
      required String id,
      required String name,
      required String content,
      Value<String> category,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PromptsTableUpdateCompanionBuilder =
    PromptsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> content,
      Value<String> category,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PromptsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromptsTable,
          Prompt,
          $$PromptsTableFilterComposer,
          $$PromptsTableOrderingComposer,
          $$PromptsTableAnnotationComposer,
          $$PromptsTableCreateCompanionBuilder,
          $$PromptsTableUpdateCompanionBuilder,
          (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
          Prompt,
          PrefetchHooks Function()
        > {
  $$PromptsTableTableManager(_$AppDatabase db, $PromptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromptsCompanion(
                id: id,
                name: name,
                content: content,
                category: category,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String content,
                Value<String> category = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PromptsCompanion.insert(
                id: id,
                name: name,
                content: content,
                category: category,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromptsTable,
      Prompt,
      $$PromptsTableFilterComposer,
      $$PromptsTableOrderingComposer,
      $$PromptsTableAnnotationComposer,
      $$PromptsTableCreateCompanionBuilder,
      $$PromptsTableUpdateCompanionBuilder,
      (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
      Prompt,
      PrefetchHooks Function()
    >;
typedef $$ImageCompressSettingsTableCreateCompanionBuilder =
    ImageCompressSettingsCompanion Function({
      Value<int> minSize,
      required int quality,
      required String label,
      Value<int> maxWidth,
    });
typedef $$ImageCompressSettingsTableUpdateCompanionBuilder =
    ImageCompressSettingsCompanion Function({
      Value<int> minSize,
      Value<int> quality,
      Value<String> label,
      Value<int> maxWidth,
    });

class $$ImageCompressSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageCompressSettingsTable> {
  $$ImageCompressSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get minSize => $composableBuilder(
    column: $table.minSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxWidth => $composableBuilder(
    column: $table.maxWidth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImageCompressSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageCompressSettingsTable> {
  $$ImageCompressSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get minSize => $composableBuilder(
    column: $table.minSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxWidth => $composableBuilder(
    column: $table.maxWidth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageCompressSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageCompressSettingsTable> {
  $$ImageCompressSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get minSize =>
      $composableBuilder(column: $table.minSize, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get maxWidth =>
      $composableBuilder(column: $table.maxWidth, builder: (column) => column);
}

class $$ImageCompressSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageCompressSettingsTable,
          ImageCompressSetting,
          $$ImageCompressSettingsTableFilterComposer,
          $$ImageCompressSettingsTableOrderingComposer,
          $$ImageCompressSettingsTableAnnotationComposer,
          $$ImageCompressSettingsTableCreateCompanionBuilder,
          $$ImageCompressSettingsTableUpdateCompanionBuilder,
          (
            ImageCompressSetting,
            BaseReferences<
              _$AppDatabase,
              $ImageCompressSettingsTable,
              ImageCompressSetting
            >,
          ),
          ImageCompressSetting,
          PrefetchHooks Function()
        > {
  $$ImageCompressSettingsTableTableManager(
    _$AppDatabase db,
    $ImageCompressSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageCompressSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImageCompressSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImageCompressSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> minSize = const Value.absent(),
                Value<int> quality = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> maxWidth = const Value.absent(),
              }) => ImageCompressSettingsCompanion(
                minSize: minSize,
                quality: quality,
                label: label,
                maxWidth: maxWidth,
              ),
          createCompanionCallback:
              ({
                Value<int> minSize = const Value.absent(),
                required int quality,
                required String label,
                Value<int> maxWidth = const Value.absent(),
              }) => ImageCompressSettingsCompanion.insert(
                minSize: minSize,
                quality: quality,
                label: label,
                maxWidth: maxWidth,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImageCompressSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageCompressSettingsTable,
      ImageCompressSetting,
      $$ImageCompressSettingsTableFilterComposer,
      $$ImageCompressSettingsTableOrderingComposer,
      $$ImageCompressSettingsTableAnnotationComposer,
      $$ImageCompressSettingsTableCreateCompanionBuilder,
      $$ImageCompressSettingsTableUpdateCompanionBuilder,
      (
        ImageCompressSetting,
        BaseReferences<
          _$AppDatabase,
          $ImageCompressSettingsTable,
          ImageCompressSetting
        >,
      ),
      ImageCompressSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DealsTableTableManager get deals =>
      $$DealsTableTableManager(_db, _db.deals);
  $$DealTagsTableTableManager get dealTags =>
      $$DealTagsTableTableManager(_db, _db.dealTags);
  $$DealPromotionsTableTableManager get dealPromotions =>
      $$DealPromotionsTableTableManager(_db, _db.dealPromotions);
  $$CouponsTableTableManager get coupons =>
      $$CouponsTableTableManager(_db, _db.coupons);
  $$DealImagesTableTableManager get dealImages =>
      $$DealImagesTableTableManager(_db, _db.dealImages);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$SyncChangelogTableTableManager get syncChangelog =>
      $$SyncChangelogTableTableManager(_db, _db.syncChangelog);
  $$BackupRecordsTableTableManager get backupRecords =>
      $$BackupRecordsTableTableManager(_db, _db.backupRecords);
  $$AiConfigsTableTableManager get aiConfigs =>
      $$AiConfigsTableTableManager(_db, _db.aiConfigs);
  $$SecretsTableTableManager get secrets =>
      $$SecretsTableTableManager(_db, _db.secrets);
  $$PromptsTableTableManager get prompts =>
      $$PromptsTableTableManager(_db, _db.prompts);
  $$ImageCompressSettingsTableTableManager get imageCompressSettings =>
      $$ImageCompressSettingsTableTableManager(_db, _db.imageCompressSettings);
}
