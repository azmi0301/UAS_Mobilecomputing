import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/recipe.dart';
import 'models/meal_plan.dart';
import 'models/grocery_item.dart';
import 'providers/recipe_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(MealPlanAdapter());
  Hive.registerAdapter(GroceryItemAdapter());

  await Hive.openBox<Recipe>('recipes');
  await Hive.openBox<MealPlan>('meal_plans');
  await Hive.openBox<GroceryItem>('groceries');
  await Hive.openBox('users');
  await Hive.openBox('auth');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipeProvider()..seedDefaultsIfEmpty(),
        ),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
        ChangeNotifierProvider(create: (_) => GroceryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ResepKu',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}

