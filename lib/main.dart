import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/home_page.dart';
import 'package:myapp/model/sehir_model.dart';
import 'package:myapp/services/selected_list_item.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Şeffaf yapmak için
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SelectedListItemAdapter());
  Hive.registerAdapter(IllerAdapter());
  Hive.registerAdapter(IlcelerAdapter());
  await Hive.openBox('appData');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: Colors.red,
        fontFamily: 'Poppins',
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

/*
git remote add origin https://github.com/meminglr/Nobetci-Eczane.git
git remote add origin https://github.com/meminglr/Nobetci-Eczane.git
git push -u origin main

echo "# Nobetci-Eczane" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/meminglr/Nobetci-Eczane.git
git push -u origin main
*/
