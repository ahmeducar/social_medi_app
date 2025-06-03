import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/pages/account_settings_page.dart';
import 'package:twitter_clone_app/pages/blocked_users_page.dart';
import 'package:twitter_clone_app/pages/home_page.dart';
import 'package:twitter_clone_app/pages/post_page.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';

//* burada da hangi fonksiyon çağırıldığında hangi sayfaya yönlendireceği yazıyor

//* örneğin goUserPage fonksiyonu çağırıldığında ProfilePage sayfasına yönleniyor.

void goUserPage(BuildContext context,String uid){
  Navigator.push(context,
  MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)
    )
  );
}

//* bu fonksiyonda post sayfasına yönlendir gibi gibi
//* go to post page
void goPostPage(BuildContext context,Post post){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );

}
  //* go to blocked user page
  void goBlockedUsersPage(BuildContext context){
    //* navigate to page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlockedUsersPage(),
      ),
    );
  }

  void goAccountSettingsPage(BuildContext context){
    //* navigate to page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSettingsPage(),
      ),
    );
  }


//* go home page but remove all previous routes this is good for reload
void goHomePage(BuildContext context){
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage()
      ),
    (route) => route.isFirst);
}