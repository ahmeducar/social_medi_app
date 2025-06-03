import 'package:flutter/material.dart';


//* drawer yanda çıkan menü ona dokunduğunda örneğin ayarlar çıkış gibi şeyler olacak
class MyDrawerTile extends StatelessWidget {

  //* burası sabit kalacak o yüzden stateless ile oluştu ayrıca bir çıkış ya da başka bir şey bir title bir icon ve 
  //* tıklandığında bir işlem olması için onTap alacak
  final String title;
  final IconData icon;
  final void Function()? onTap;


  //* required belirtiyoruz
  const MyDrawerTile(
    {super.key,
      required this.title,
      required this.icon,
      required this.onTap
    });


  //* drawerda örneğin settings yazacak ve bir iconu olacak ve tıklandığında bir yere gidilecek o yüzden 
  //* onTap , icon ve title kısmını yazıyoruz
  //* yani aslında burası bir class oluşturulmuş gibi 
  //* sonradan burası gösterilerek drawer oluşturucaz 
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
      style: TextStyle(
        color: Theme.of(context).
        colorScheme.
        inversePrimary),
        ),
      leading: Icon(icon,
      color: Theme.of(context).
      colorScheme.primary),
      onTap: onTap,
    );
  }
}