import 'package:flutter/material.dart';


//* mesajlaşma için oluşturulmuş bir buton kendisi 
class MyMessageButton extends StatelessWidget {

  //* tıklanma durumunu onPressed ile tanımladık 
  final void Function()? onPressed;

  //* required ile onu vermek zorundayız
  const MyMessageButton({
    super.key,
    required this.onPressed,
  });

  //* içerisinde Mesaj Gönder yazan bir butonun şeklini şemalini verdik sadece ve onPressed parametres vermiştik.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: MaterialButton(
          padding: EdgeInsets.all(16),
          onPressed: onPressed,
          color: Colors.blue, // Buton rengi
          child: Text(
            "Mesaj Gönder",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary, // Yazı rengi
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
