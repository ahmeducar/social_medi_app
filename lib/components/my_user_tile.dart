import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {

  //* UserProfile sınıfından oluşmuş bir user nesnesi 
  final UserProfile user;

  const MyUserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 5),

      padding: EdgeInsets.all(5),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.secondary,
      ),
      //* List tile 
      child: ListTile(
        //* name yazıyor kullanıcının
        title: Text(user.name),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary),
        
        //* username yazıyor
        subtitle: Text('@${user.username}'),
        subtitleTextStyle: TextStyle(
          color:Theme.of(context).colorScheme.primary),
        
        //* icon  insan iconu gösteriyor
        leading:Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary),
        
        //* ON TOP dokunma kısmı kişiye dokunulduğunda onun sayfasına yönlendirme kısmı 
        onTap: () => Navigator.push(
          context, MaterialPageRoute(
            builder: (context) => ProfilePage(uid: user.uid)
            )
          ),

        //* arrow forward icon bu da yana doğru çıkan 
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}