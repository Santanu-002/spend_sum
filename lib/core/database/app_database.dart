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
  TextColumn get currency => text().nullable()();

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

/// SQLite schema definition for Country Codes, Flags, and Currency Symbols.
class CountryCurrencies extends Table {
  TextColumn get code => text()(); // e.g. "+91"
  TextColumn get flag => text()(); // e.g. "🇮🇳"
  TextColumn get name => text()(); // e.g. "India"
  IntColumn get maxLength => integer()(); // e.g. 10
  TextColumn get currencySymbol => text()(); // e.g. "₹"
  TextColumn get currencyLabel => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {code};
}

/// The Drift SQLite reactive database for SpendSum.
@DriftDatabase(tables: [Expenses, Categories, Users, Budgets, CountryCurrencies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
        if (from < 4) {
          await m.createTable(countryCurrencies);
        }
        if (from < 5) {
          await m.addColumn(users, users.currency);
        }
        if (from < 6) {
          await m.addColumn(countryCurrencies, countryCurrencies.currencyLabel);
        }
      },
      beforeOpen: (details) async {
        final existing = await select(categories).get();
        final needsSeeding = existing.isEmpty || existing.any((c) => c.icon.contains('_'));
        if (needsSeeding) {
          await delete(categories).go();
          final defaultCategories = [
            const CategoriesCompanion(name: Value('Groceries'), icon: Value('f0170'), color: Value('0xFF00B475')),
            const CategoriesCompanion(name: Value('Travel'), icon: Value('f54c'), color: Value('0xFF5AC8FA')),
            const CategoriesCompanion(name: Value('Car'), icon: Value('f6b3'), color: Value('0xFF007AFF')),
            const CategoriesCompanion(name: Value('Home'), icon: Value('f7f5'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Insurances'), icon: Value('f016b'), color: Value('0xFF00B475')),
            const CategoriesCompanion(name: Value('Education'), icon: Value('f012e'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Marketing'), icon: Value('f614'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('shopping'), icon: Value('f016f'), color: Value('0xFF00B475')),
            const CategoriesCompanion(name: Value('Internet'), icon: Value('f02bf'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Water'), icon: Value('f03b4'), color: Value('0xFF007AFF')),
            const CategoriesCompanion(name: Value('Rent'), icon: Value('f0343'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Gym'), icon: Value('f767'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Subscription'), icon: Value('f002a'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Vacation'), icon: Value('f5b3'), color: Value('0xFF00B475')),
            const CategoriesCompanion(name: Value('Food'), icon: Value('f0108'), color: Value('0xFFFF2D55')),
            const CategoriesCompanion(name: Value('Entertainment'), icon: Value('f87a'), color: Value('0xFFFF9500')),
            const CategoriesCompanion(name: Value('Health'), icon: Value('f8b0'), color: Value('0xFFFF3B30')),
            const CategoriesCompanion(name: Value('Bills'), icon: Value('f00e1'), color: Value('0xFFFFCC00')),
            const CategoriesCompanion(name: Value('Savings'), icon: Value('f0128'), color: Value('0xFF00B475')),
            const CategoriesCompanion(name: Value('Other'), icon: Value('f58f'), color: Value('0xFF5856D6')),
            const CategoriesCompanion(name: Value('Salary'), icon: Value('f58f'), color: Value('0xFF00B475'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Freelance'), icon: Value('f02c7'), color: Value('0xFF5AC8FA'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Investments'), icon: Value('f0254'), color: Value('0xFF5856D6'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Gifts'), icon: Value('f61a'), color: Value('0xFFFF2D55'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Bonus'), icon: Value('f00e6'), color: Value('0xFFFF9500'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Refunds'), icon: Value('f0156'), color: Value('0xFF007AFF'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Rental'), icon: Value('f676'), color: Value('0xFFFFCC00'), isExpense: Value(false)),
            const CategoriesCompanion(name: Value('Other Income'), icon: Value('f0058'), color: Value('0xFFFFCC00'), isExpense: Value(false)),
          ];
          for (final cat in defaultCategories) {
            await into(categories).insert(cat);
          }
        }

        final defaultCountryCurrencies = [
          const CountryCurrenciesCompanion(
            code: Value('+91'),
            flag: Value('🇮🇳'),
            name: Value('India'),
            maxLength: Value(10),
            currencySymbol: Value('₹'),
            currencyLabel: Value('INR'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+1'),
            flag: Value('🇺🇸'),
            name: Value('United States'),
            maxLength: Value(10),
            currencySymbol: Value('\$'),
            currencyLabel: Value('USD'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+44'),
            flag: Value('🇬🇧'),
            name: Value('United Kingdom'),
            maxLength: Value(10),
            currencySymbol: Value('£'),
            currencyLabel: Value('GBP'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+65'),
            flag: Value('🇸🇬'),
            name: Value('Singapore'),
            maxLength: Value(8),
            currencySymbol: Value('S\$'),
            currencyLabel: Value('SGD'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+61'),
            flag: Value('🇦🇺'),
            name: Value('Australia'),
            maxLength: Value(9),
            currencySymbol: Value('A\$'),
            currencyLabel: Value('AUD'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+33'),
            flag: Value('🇫🇷'),
            name: Value('France'),
            maxLength: Value(9),
            currencySymbol: Value('€'),
            currencyLabel: Value('EUR'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+81'),
            flag: Value('🇯🇵'),
            name: Value('Japan'),
            maxLength: Value(10),
            currencySymbol: Value('¥'),
            currencyLabel: Value('JPY'),
          ),
          const CountryCurrenciesCompanion(
            code: Value('+84'),
            flag: Value('🇻🇳'),
            name: Value('Vietnam'),
            maxLength: Value(9),
            currencySymbol: Value('đ'),
            currencyLabel: Value('VND'),
          ),
        ];
        for (final entry in defaultCountryCurrencies) {
          await into(countryCurrencies).insert(entry, mode: InsertMode.insertOrReplace);
        }

        // Seed default user if not exists
        final defaultUserExisting = await (select(users)..where((t) => t.phoneNumber.equals('+919876543210'))).getSingleOrNull();
        if (defaultUserExisting == null) {
          const defaultUserUid = 'usr9876543'; // exactly 10 characters
          await into(users).insert(const UsersCompanion(
            uid: Value(defaultUserUid),
            phoneNumber: Value('+919876543210'),
            name: Value('Santanu Dev'),
            isNew: Value(false),
            isBudgetCompleted: Value(true),
            currency: Value('₹'),
          ));

          await into(budgets).insert(BudgetsCompanion(
            userUid: const Value(defaultUserUid),
            amount: const Value(50000.0),
            period: const Value('Monthly'),
            createdAt: Value(DateTime.now()),
          ));

          final now = DateTime.now();
          final currentYear = now.year;
          for (int i = 0; i < 57; i++) {
            var txDate = DateTime(now.year, now.month, now.day).subtract(
              Duration(days: i + 1, hours: (i * 3) % 24, minutes: (i * 7) % 60),
            );
            if (txDate.year != currentYear) {
              txDate = DateTime(currentYear, 1, 1).add(Duration(hours: i));
            }

            final isIncome = (i % 5 == 0);
            final double amount;
            final String category;
            final String title;

            if (isIncome) {
              if (i % 10 == 0) {
                category = 'Salary';
                title = 'Salary Credit';
                amount = 60000.0;
              } else {
                category = 'Freelance';
                title = 'Freelance Project Pay';
                amount = 12500.0 + (i * 100);
              }
            } else {
              final expType = i % 12;
              switch (expType) {
                case 1:
                  category = 'Groceries';
                  title = 'Weekly Groceries';
                  amount = 1500.0 + (i * 15);
                  break;
                case 2:
                  category = 'Travel';
                  title = 'Petrol Refuel';
                  amount = 1200.0 + (i * 10);
                  break;
                case 3:
                  category = 'Food';
                  title = 'Restaurant Dinner';
                  amount = 850.0 + (i * 5);
                  break;
                case 4:
                  category = 'Entertainment';
                  title = 'Movie Ticket';
                  amount = 450.0;
                  break;
                case 5:
                  category = 'shopping';
                  title = 'New Clothes';
                  amount = 3200.0;
                  break;
                case 6:
                  category = 'Internet';
                  title = 'Wifi Bill';
                  amount = 999.0;
                  break;
                case 7:
                  category = 'Rent';
                  title = 'Monthly Room Rent';
                  amount = 12000.0;
                  break;
                case 8:
                  category = 'Gym';
                  title = 'Gym Fee';
                  amount = 1500.0;
                  break;
                case 9:
                  category = 'Water';
                  title = 'Water Delivery';
                  amount = 350.0;
                  break;
                case 10:
                  category = 'Subscription';
                  title = 'Streaming Subscription';
                  amount = 649.0;
                  break;
                case 11:
                  category = 'Bills';
                  title = 'Electric Bill';
                  amount = 2200.0;
                  break;
                default:
                  category = 'Other';
                  title = 'App Purchase';
                  amount = 250.0;
                  break;
              }
            }

            await into(expenses).insert(ExpensesCompanion(
              userUid: const Value(defaultUserUid),
              title: Value(title),
              amount: Value(amount),
              date: Value(txDate),
              category: Value(category),
              isIncome: Value(isIncome),
            ));
          }
        } else if (defaultUserExisting.currency == null || defaultUserExisting.currency!.trim().isEmpty) {
          await update(users).replace(defaultUserExisting.copyWith(currency: const Value('₹')));
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

  // --- Helper CRUD queries for Country Currencies ---
  Future<List<CountryCurrency>> getAllCountryCurrencies() =>
      select(countryCurrencies).get();
}

/// Helper connection factory using the background native sqlite database executor.
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spend_sum.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
