import 'package:flutter/material.dart';

class MybioBox extends StatelessWidget {
  final String text;
  
  const MybioBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    //* bir kutucuk olması için return içerisinde bir kontainer kullanılmış
    return Container(
      
      //* margin verilmiş
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
      //* padding verilmiş
      padding: EdgeInsets.all(25),

      //* kutucuk bir köşeleri eğik olacak kutucuk şekli için yapılmış
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),

      //* konteynir içerisine bir Text yazılacak o yüzden texy widget kullanılıyor
      child: Text(
        
        //* Eğer text boşsa ? ile sağlanıyor isEmpty bir fonksiyon, "Boş biografi" yazsın, değilse (: ile değilse anlamı var) gerçek biyografiyi göstersin
        
        text.isEmpty ? "Boş biografi" : text,

        //* textin yazı şekli belirtiliyor istersek fontsize ya da kalınlık yazabiliriz
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
