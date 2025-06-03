import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';


//* settings kısmında bloklanmış kullanıcılara tıklandığında yönlendirdiği sayfanın kodları
//* bloke edilen kullanıcılar ve bloke kaldırılıyor bazen o yüzden stateful widget 
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {

  //*providers
  late final listeninProvider = 
    Provider.of<DatabaseProvider>(context);
  late final databaseProvider = 
    Provider.of<DatabaseProvider>(context,listen:false);

  //* on startup
  @override
  void initState() {
    super.initState();
    loadBlockedUsers();
  }

  //* load blocked users
  Future<void> loadBlockedUsers () async{
    //* database provider dosyasında ki loadBlockedUsers fonksiyonu kullanılıyor. void yanında ki fonks adı ile await ile kullanılan 
    //* aynı değil aslında
    await databaseProvider.loadBlockedUsers();
  }

  //* show unblock user box dialog

  //* her blocklanan kişi bir kutucuk içerisinde oluyor o icona basınca gelen şey budur 
  void _showUnblockBox(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //* diyalog içerisinde yazan başta yazan
        title: const Text("Kullanıcı Blokesini kaldır"),
        //* içerik olan olarak yazan metin 
        content: const Text("Emin misin? Kullanıcıda ki blokeyi kaldırmak istiyor musun?"),
        actions: [
          //* yan yana olacak şekilde iptal ve bloke kaldır butonları bulunuyor.
          //* iptal olursa eski sayfaya döner
          TextButton(
            child: Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          //* unblock butonu basarsa hem eski sayfaya döner hem de 
          TextButton(
            child: Text("Bloke Kaldır"),
            onPressed: () async {
              Navigator.pop(context);

              //* Blokeyi kaldırma fonksiyonu devreye giriyor database provider dart dosyasında oluşmuş fonksiyon 
              await databaseProvider.unblockUser(userId);

              //* close box
              if (context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User unblocked!"))
                );
              }
            },
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    //* listen to blocked users
    final blockedUsers = listeninProvider.blockedUsers;

    //* blocklanmış kullanıclar yazıyor appbarda ve asıl sayfa düzeni burada
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Blocklanmış Kullanıcılar'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //* blocklu kullanıcı boş mu diye soruyor boşsa şuanda blocklanmış kullanıcı yok
      body: blockedUsers.isEmpty 
        ? 
          Center(
            child:
              Text("Şu anda blocklanmış kullanıcı yok."),
        ) 
        //* eğer boş değilse listView widget ile bloklanmış olanlar user değişkenine atanıyor
        : ListView.builder(
          itemCount: blockedUsers.length,
          itemBuilder: (context, index) {
            final user = blockedUsers[index];
            
            //* listTile ile blocklanmış olanlar isim ve 
            //* return as a ListTile
            return ListTile(
              title:Text(user.name),  //* örneğin Gönül
              subtitle:Text('@${user.username}'),  //* @gonul şeklinde gösteriliyor 
              trailing: IconButton(
                icon: const Icon(Icons.block),  //* block ikonu ikona basılırsa kutucuk gösterilecek

                //* butona basıldığı zaman aşağıda ki fonksyion çalışacak
                onPressed: () => _showUnblockBox(user.uid),
              ),
            );
          },
       )
      );
    }
}
