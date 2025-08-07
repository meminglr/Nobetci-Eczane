import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/screens/exapndebele_map.dart';
import 'package:myapp/screens/first_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/silver_screen.dart';
import 'package:myapp/screens/sliver_screen2.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Data> eczaneListesi = [];
  HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.loadData();
    controller.illeriGetir().then((onValue) => controller.modelToString());
  }

  @override
  Widget build(BuildContext context) {
    final box = controller.box;
    EczaneService eczaneService = EczaneService();
    Companents companents = Companents();

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ['isFirst']),
      builder: (context, Box box, _) {
        bool isFirst = box.get('isFirst', defaultValue: true);

        // Eğer ilk sayfa ise:
        if (isFirst) {
          return FirstScreen(companents: companents, controller: controller);
        } else {
          return SilverScreenView(
            controller: controller,
            eczaneService: eczaneService,
            companents: companents,
          );
        }
      },
    );
  }
}
