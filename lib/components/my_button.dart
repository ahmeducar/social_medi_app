import 'package:flutter/material.dart';


//* genel bir buton sınıfı oluşturuluyor buton içerisinde bir yazı yazacak o text ile belirtiliyor
//* butona dokunulduğunda işlem yapılması olayı ise onTap ile belirtiliyor  

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  //* belirtilenlerin onTap ve textin required alması lazım
  const MyButton({
  super.key,
  required this.onTap,
  required this.text,
  });


  //* onTap işlemini GestureDetector ile kullanıyor o yüzden bu widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //* dokunma kısmı
      onTap: onTap,
      //* parent child muhabbeti ile child çocuk belirliyoruz parenti GestureDetector child kısmı ise bir kutucuk yine kontainer
      child: Container(

        //* kutucuğa yine şekiller şemaller falan veriliyor
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(16)
        ),

        //* center kullanma amacı kutucuğun ortasına bir şekil şemal yazı yazılacak ondan
        child: Center(

          //* dediğim gibi içerisine yazı yazılacak text o da 
          child: Text(
            text,

            //* texte şekil vermek için 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )
          )
        ),
      ),
    );
  }
}