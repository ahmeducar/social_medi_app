import 'package:flutter/material.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';


//* settings kısmında ki hesap ayarı sayfası için oluşturulmuş stateful widget kullanılıyor
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {

  //* ask for confirmation from the user before deleting their account

  void confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabı Sil"),
        content: const Text("Emin misin? Bu hesabı silmek istiyor musun?"),
        actions: [
          TextButton(
            child: Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Sil"),
            onPressed: () async {
              //*DELETE BUTTON  butona basınca hesap silinecek fonksiyonu auth service dart dosyasında 
              await AuthService().deleteAccount();

              
              //* then navigate to initial route (auth gate -> login / register page) 
              if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false,);
              }
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Hesap Ayarları"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children: [
          GestureDetector(
            //* butona tıklama olayını GestureDetector widgeti ile yapıyoruz onTap ile confirmDeletion fonksiyonu çağrılıyor
            onTap: () => confirmDeletion(context),
            //* confirmDeletion fonksiyonu da deleteAccount fonksiyonu ile hesabı siliyor ve login or register atıyor.
            child: Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Hesabı Sil",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}