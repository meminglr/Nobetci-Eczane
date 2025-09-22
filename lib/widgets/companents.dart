import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home_controller.dart';

class Companents {
  FilledButton ilceSelectButton(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: controller.yeniIcelerListesi,
            onSelected: (ilceSelectedItem) {
              controller.secilenIlce = ilceSelectedItem[0].data;
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Text(
        controller.secilenIlce == null
            ? "İlçe Seçiniz"
            : controller.secilenIlce!,
      ),
    );
  }

  FilledButton ilSelectButton(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "Şehir Ara",
            data: controller.yeniIllerListesi,
            onSelected: (ilSelectedItem) {
              controller.secilenSehir = ilSelectedItem[0].data;
              controller.secilenIlce = null;
              controller.secilenIlinIlceleriniGetir(controller.secilenSehir!);
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Text(
        controller.secilenSehir == null
            ? "Şehir Seçiniz"
            : controller.secilenSehir!,
      ),
    );
  }

  FilledButton firstScreenIlce(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: controller.yeniIcelerListesi,
            onSelected: (ilceSelectedItem) async {
              controller.secilenIlce = await ilceSelectedItem[0].data;
              controller.isFirst = false;
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          controller.secilenIlce == null
              ? "İlçe Seçiniz"
              : controller.secilenIlce!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  FilledButton firstScreenIl(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "Şehir Ara",
            data: controller.yeniIllerListesi,
            onSelected: (ilSelectedItem) {
              controller.secilenSehir = ilSelectedItem[0].data;
              controller.secilenIlce = null;
              controller.secilenIlinIlceleriniGetir(controller.secilenSehir!);
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          controller.secilenSehir == null
              ? "Şehir Seçiniz"
              : controller.secilenSehir!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  Container floatingActionButton({
    required BuildContext context,
    required HomeController controller,
    required Companents companents,
    required VoidCallback onChanged,
    required VoidCallback onChanged2,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Beyaz arkaplan
        borderRadius: BorderRadius.circular(20), // Yuvarlak köşeler
        boxShadow: [
          BoxShadow(
            // İstersen hafif gölge ekleyebilirsin
            color: Colors.black26,
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          companents.ilSelectButton(context, controller, () {
            onChanged();
          }),
          SizedBox(width: 5), // spacing yerine SizedBox kullandım
          companents.ilceSelectButton(context, controller, () {
            onChanged2();
          }),
        ],
      ),
    );
  }
}
