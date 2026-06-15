import 'package:drift/drift.dart';

class Prompts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get content => text()();
  TextColumn get category => text().withDefault(const Constant('custom'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
