import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/screens/first_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';

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
    EczaneService eczaneService = EczaneService();
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
            onNext: () {
              // sayfa geçişi
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder:
                      (context) => MainScrenn(
                        controller: controller,
                        eczaneService: eczaneService,
                        companents: companents,
                      ),
                ),
              );
            },
          );
        }

        return MainScrenn(
          controller: controller,
          eczaneService: eczaneService,
          companents: companents,
        );
      },
    );
  }
}

class EczaneItem extends StatelessWidget {
  final List<Data> data;

  final EczaneService eczaneService;

  const EczaneItem({
    super.key,
    required this.data,
    required this.eczaneService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                    onTap: () {
                      eczaneService.openMap(item.latitude!, item.longitude!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20),
                          right: Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, color: Colors.blue[100]),
                          Text(
                            "Harita",
                            style: TextStyle(color: Colors.blue[100]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.pharmacyName!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(item.address!, style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                    onTap: () {
                      eczaneService.makePhoneCall(item.phone!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(20),

                          left: Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_outlined, color: Colors.green[100]),
                          Text(
                            "Ara",
                            style: TextStyle(color: Colors.green[100]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
