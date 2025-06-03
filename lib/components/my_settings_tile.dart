import 'package:flutter/material.dart';


/*



*/


//* AYARLAR SAYFASI kişi buraya girdiğinde dark ve light mode açacak 

//* onun asıl settings page dosyasının oluştuğu sınıfı yazıyoruz burada


class MySettingsTile extends StatelessWidget {

  final String title;
  final Widget action;
  
  const MySettingsTile({
    super.key,
    required this.action,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24)
      ),
      margin: EdgeInsets.only(left: 25, right: 25, top: 10),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          action,
        ],
      )
    );
  }
}