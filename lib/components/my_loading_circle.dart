import 'package:flutter/material.dart';


//* burası sadece örneğin bir kayıt oluşturulacak ya da giriş yaparken bir dönen muhabbet var onu göstermek için 
void showLoadingCircle(BuildContext context){
  showDialog(
    context: context,
    builder: (context)=>AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          
        ),
      ),
    )
  );
}

//* bunu anlamadım aq 
void hideLoadingCircle(BuildContext context){
  Navigator.pop(context);
}