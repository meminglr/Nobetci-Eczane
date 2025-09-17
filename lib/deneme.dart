import 'package:flutter/material.dart';
import 'package:myapp/model/yeni_eczane_model.dart';
import 'package:myapp/services/yeni_eczane_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Deneme extends StatefulWidget {
  const Deneme({super.key});

  @override
  State<Deneme> createState() => _DenemeState();
}

class _DenemeState extends State<Deneme> {
  bool isLoading = true;
  List<YeniEczane> eczaneList = [];
  YeniEczaneService yeniEczaneService = YeniEczaneService();

  Future<void> getData() async {
    eczaneList = await yeniEczaneService.getEczane("adana", "seyhan");
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse("geo:0,0?q=ŞİFA ECZANESİ HASKÖY MUS"),
                      );
                    },
                    child: Text("data"),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: eczaneList.length,
                      itemBuilder: (context, index) {
                        var item = eczaneList[index];
                        return Text(item.name!);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
