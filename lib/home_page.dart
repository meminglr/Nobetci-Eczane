import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nobetcieczane/home_controller.dart';
import 'package:nobetcieczane/screens/first_screen.dart';
import 'package:nobetcieczane/screens/eczane_screen.dart';
import 'package:nobetcieczane/services/yeni_eczane_service.dart';
import 'package:nobetcieczane/widgets/companents.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    YeniEczaneService yeniEczaneService = YeniEczaneService();
    Companents companents = Companents();

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ['isFirst']),
      builder: (context, Box box, _) {
        bool isFirst = box.get('isFirst', defaultValue: true);

        // Eğer ilk sayfa ise:
        if (isFirst) {
          return FirstScreen(
            companents: companents,
            controller: controller,
            yeniEczaneService: yeniEczaneService,
          );
        } else {
          return EczaneScreen(
            controller: controller,
            eczaneService: yeniEczaneService,
            companents: companents,
          );
        }
      },
    );
  }
}
