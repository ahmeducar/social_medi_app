import 'package:flutter/material.dart';
import 'package:twitter_clone_app/themes/dark_mode.dart';
import 'package:twitter_clone_app/themes/light_mode.dart';

//* light ve dark mode geçişini yapmak için açıyoruz.

class ThemeProvider with ChangeNotifier {
  // başlangıçta light mode kullanıcaz 

  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  // dark modda mı 

  bool get isDarkMode => _themeData == darkMode;


  // temayı belirliyoruz
  set themeData(ThemeData themeData){
    _themeData = themeData;

    // update kısmı 
    notifyListeners();
  }

  void toggleTheme (){
    if(_themeData == lightMode){
      themeData = darkMode;
    }else {
      themeData = lightMode;
    }
  }
}