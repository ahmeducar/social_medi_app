import 'package:flutter/material.dart';

//* içerisine bir şey yazdığımız bir kutucuğuk

class MyInputAlertBox extends StatelessWidget {
  
  //* TextEditingController zaten var olan bir şey biz textController ismi ile tanımlama yaptık 
  //* hinttext içerisinde bir şey yazmıyorsa örneğin twitterda ne düşünüyorsun yazıyordu tıkladığımızda o gidiyordu o işte hinttext
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  //* bu hinttext ve diğer parametreler sonradan oluşturulacak yani biz sadece bu textfield için bir sınıf oluşturuyoruz 
  //* başka sayfalarda bunu kullancağız neden böyle yapıldı
  //* 1. bence temiz kod ve 2. si her seferinde her bir textfield oluşturulacağında tekrar tekrar oluşturmamak için


  //* required ile yazıyoruz burada
  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });


  //* TextField yani içerisine yazı yazılacak şeyi burada oluşturuyoruz örneğin 
  //* giriş yap ve kaydol sayfalarında bu TextField olacak ve içerisine nicki veya email gibi şeyleri yazıcaz
  @override
  Widget build(BuildContext context) {
    
    //*bir diyalog oluşturuldu ve bu diyaloğun şekilleri belli oluyor.
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      
      //*AlertDiyalog içeriği ne olacak bir Textfield olacak o yüzden yazdık
      content: TextField(
        controller: textController,
        maxLength: 140,
        maxLines: 3,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          //* dışarıdan alacak hintTexti şimdi verdiğimiz hintText tanımlamasına atadık
          hintText: hintText,
          //* orada yazacak yazının şekli
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          counterStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      //* TextField içerisinde olacak olaylar
      actions: [  
        //* butona tıklanınca geri dön ve controllerla takip edilen yazıyı sil diyoruz
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          //* iptap yazısı var yani iptal yazısı olan butona tıklanınca o yazı silinecek
          child: Text("İptal"),
        ),
        TextButton(
          //* içeriği onPressedText olana tıklandığında silecek
          onPressed: () {
            Navigator.pop(context);
            onPressed!();
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}
