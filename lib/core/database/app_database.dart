import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

/// SQLite schema definition for Expense records.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userUid => text().nullable().references(Users, #uid)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
}

/// SQLite schema definition for Expense/Income Categories.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text()();
  TextColumn get color => text()(); // Hex representation
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();
}

/// SQLite schema definition for Users.
class Users extends Table {
  TextColumn get uid => text().withLength(min: 10, max: 10)();
  TextColumn get phoneNumber => text().unique()();
  TextColumn get name => text().nullable()();
  DateTimeColumn get dob => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get isNew => boolean().withDefault(const Constant(true))();
  BoolColumn get isBudgetCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {uid};
}

/// SQLite schema definition for Budget surveys.
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userUid => text().references(Users, #uid)();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// The Drift SQLite reactive database for SpendSum.
@DriftDatabase(tables: [Expenses, Categories, Users, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(expenses, expenses.isIncome);
        }
        if (from < 3) {
          await m.addColumn(expenses, expenses.userUid);
        }
      },
      beforeOpen: (details) async {
        final existing = await select(categories).get();
        if (existing.isEmpty) {
          final defaultCategories = [
            const CategoriesCompanion(name: Value('Groceries'), icon: Value('shopping_basket_rounded'), color: Value('0xFF4CD964')),
            const CategoriesCompanion(name: Value('Travel'), icon: Value('airplanemode_active_rounded'), color: Value('0xFF5AC8FA')),
            const CategoriesCompanion(name: Value('Car'), icon: Value('directions_car_rounded'), color: Value('0xFF007AFF')),
            const CategoriesCompanion(name: Value('Home'), icon: Value('home_rounded'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Insurances'), icon: Value('shield_rounded'), color: Value('0xFF4CD964')),
            const CategoriesCompanion(name: Value('Education'), icon: Value('school_rounded'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Marketing'), icon: Value('campaign_rounded'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('shopping'), icon: Value('shopping_bag_rounded'), color: Value('0xFF4CD964')),
            const CategoriesCompanion(name: Value('Internet'), icon: Value('wifi_rounded'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Water'), icon: Value('water_drop_rounded'), color: Value('0xFF007AFF')),
            const CategoriesCompanion(name: Value('Rent'), icon: Value('key_rounded'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Gym'), icon: Value('fitness_center_rounded'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Subscription'), icon: Value('notifications_rounded'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Vacation'), icon: Value('beach_access_rounded'), color: Value('0xFF4CD964')),
            const CategoriesCompanion(name: Value('Food'), icon: Value('restaurant_rounded'), color: Value('0xFFFF2D55')),
            const CategoriesCompanion(name: Value('Entertainment'), icon: Value('local_play_rounded'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Health'), icon: Value('medical_services_rounded'), color: Value('0xFFFF3B30')),
            const CategoriesCompanion(name: Value('Bills'), icon: Value('receipt_long_rounded'), color: Value('0xFFFFCC00')),
            const CategoriesCompanion(name: Value('Savings'), icon: Value('savings_rounded'), color: Value('0xFF4CD964')),
            const CategoriesCompanion(name: Value('Other'), icon: Value('apps_rounded'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Salary'), icon: Value('attach_money_rounded'), color: Value('0xFF4CD964'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Freelance'), icon: Value('work_rounded'), color: Value('0xFF5AC8FA'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Investments'), icon: Value('trending_up_rounded'), color: Value('0xFF5856D6'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Gifts'), icon: Value('card_giftcard_rounded'), color: Value('0xFFFF2D55'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Bonus'), icon: Value('redeem_rounded'), color: Value('0xFFFF9500'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Refunds'), icon: Value('settings_backup_restore_rounded'), color: Value('0xFF007AFF'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Rental'), icon: Value('corporate_fare_rounded'), color: Value('0xFFFFCC00'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Other Income'), icon: Value('payments_rounded'), color: Value('0xFFFFCC00'), isExpense: Value(false)),
          ];
          for (final cat in defaultCategories) {
            await into(categories).insert(cat);
          }
        } else {
          final additionalCategories = [
            const CategoriesCompanion(name: Value('Bonus'), icon: Value('redeem_rounded'), color: Value('0xFFFF9500'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Refunds'), icon: Value('settings_backup_restore_rounded'), color: Value('0xFF007AFF'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Rental'), icon: Value('corporate_fare_rounded'), color: Value('0xFFFFCC00'), isExpense: Value(false)),
          ];
          for (final cat in additionalCategories) {
            final check = await (select(categories)..where((t) => t.name.equals(cat.name.value))).get();
            if (check.isEmpty) {
              await into(categories).insert(cat);
            }
          }
        }
      },
    );
  }

  // --- Helper CRUD queries for Expenses ---

  Stream<List<Expense>> watchAllExpensesForUser(String uid) =>
      (select(expenses)..where((t) => t.userUid.equals(uid))).watch();
  Future<List<Expense>> getAllExpensesForUser(String uid) =>
      (select(expenses)..where((t) => t.userUid.equals(uid))).get();
  Future<int> insertExpense(ExpensesCompanion companion) =>
      into(expenses).insert(companion);
  Future<bool> updateExpense(Expense entity) =>
      update(expenses).replace(entity);
  Future<int> deleteExpense(Expense entity) => delete(expenses).delete(entity);

  // --- Helper CRUD queries for Categories ---

  Stream<List<Category>> watchAllCategories() => select(categories).watch();
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<List<Category>> getCategoriesByType({required bool isExpense}) =>
      (select(categories)..where((t) => t.isExpense.equals(isExpense))).get();
  Future<int> insertCategory(CategoriesCompanion companion) =>
      into(categories).insert(companion);
  Future<bool> updateCategory(Category entity) =>
      update(categories).replace(entity);
  Future<int> deleteCategory(Category entity) =>
      delete(categories).delete(entity);

  // --- Helper CRUD queries for Users ---
  Future<User?> getUserByPhone(String phone) => (select(
    users,
  )..where((t) => t.phoneNumber.equals(phone))).getSingleOrNull();

  Future<User?> getUserByUid(String uid) =>
      (select(users)..where((t) => t.uid.equals(uid))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion companion) =>
      into(users).insert(companion);
  Future<bool> updateUser(User entity) => update(users).replace(entity);

  // --- Helper CRUD queries for Budgets ---
  Future<int> insertBudget(BudgetsCompanion companion) =>
      into(budgets).insert(companion);
  Future<List<Budget>> getBudgetsForUser(String uid) =>
      (select(budgets)..where((t) => t.userUid.equals(uid))).get();
  Stream<List<Budget>> watchBudgetsForUser(String uid) =>
      (select(budgets)..where((t) => t.userUid.equals(uid))).watch();
  Future<bool> updateBudget(Budget entity) =>
      update(budgets).replace(entity);
}

/// Helper connection factory using the background native sqlite database executor.
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spend_sum.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
