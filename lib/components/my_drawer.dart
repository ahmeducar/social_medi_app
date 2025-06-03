import 'package:flutter/material.dart';
import 'package:twitter_clone_app/components/my_drawer_tile.dart';
import 'package:twitter_clone_app/pages/login_page.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';
import 'package:twitter_clone_app/pages/search_page.dart';
import 'package:twitter_clone_app/pages/settings_page.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';

// home 
// profile 
// search 
// settings 
// logout 

//* asıl Drawer yani yan menü olan kısmı burada yazıyoruz.

//* drawer hep aynı kalacak o yüzden stateless widget ile oluşturduk 
//*extends kalıtım ile alakalı yani oop ile alakalı bir durum MyDrawer sınıfının stateless widget sınıfından oluşturulduğunu söylüyor 

class MyDrawer extends StatelessWidget {

  //* auth değişkeni yaptık _ ile sadece buraya özel bir tanım oldu AuthService() sınıfından türedi
  final _auth = AuthService();

  //* _auth başka bir sınıftan türediği için MyDrawerda super.key ile kullanılmıyor.
  MyDrawer({super.key});

  //* logOut fonksiyonu, context parametresini alacak şekilde düzenlendi

//* çıkış yapma fonksiyonu fonksiyon ismimiz logOut bunu çıkış yap butonuna bastığımızda çağırıcaz ve 
void logOut(BuildContext context) async {
  //* bu fonksiyon çağırıldığında 
  //* logout başka bir fonksiyon yani logout böyle olmalı ama   yukarıda ki logOut yerine örneğin ahmet yazardık ve 
  //* çıkış yap butonuna basıldığında Ahmet(); dediğimizde çıkış yapma işlemi gerçekleşirdi
  await _auth.logout();  // Logout işlemi
  if (context.mounted) {  // context'in hala geçerli olup olmadığını kontrol ediyoruz
    //* mounted kontrolü hep lazım fakat pushReplacement ile context parametresi veriyoruz ve material route ile
    //* LoginPage sınıfına dön diyoruz login_page.dart dosyasında LoginPage sınıfını oluşturmuştuk kullanıcı çıkış yaptığında login 
    //* sayfasına döner
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),  // Login sayfasına yönlendirme
      ),
    );
  }
}


  //* asıl drawer kısmını burada tanımlıyoruz BuildContext ve context ile
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          //* alt alta yapmak istediğimiz için column ve padding ise her zamanki gibi şekil için
          child: Column(
            children: [
              
              //* uygulama logosu insan iconu olacak şeklini ayarladık rengini ayarladık ve bir padding verdik 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 10),

              //? anasayfa listtile
              //* MyDrawerTile my_drawer_tile.dart dosyasında MyDrawerTile sınıfı oluşturmuştuk oradan çağırıyoruz
              //* ve orada 3 adet veri tutucumuz vardı title, icon ve onTap kısmı onları vermek zorundayız.
                
              MyDrawerTile(   
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);  //* bastığında bir geri gidecek demek istiyor.
                },
              ),
              MyDrawerTile(
                title: "P R O F İ L E",
                icon: Icons.person_pin,
                onTap: () {
                  Navigator.pop(context); //* bastığında bir geri gidecek diyor ve
                  //* bastığında hem geri gitti ayrıca ProfilePage sınıfına yönlendir diyor 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        //* uid si olan AuthService.dart dosyasında oluşturulan fonksiyon olan getCuttentUid olanın sayfasına git
                        //* yani uygulamaya giriş yapan kişinin kendi sayfasına gider.
                        uid: _auth.getCurrentUid(),
                      ),
                    ),
                  );
                },
              ),

              //! arama list tile kısmı
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {
                  Navigator.pop(context);
                  //* go to search page
                  Navigator.push(
                    context,        //* aynı yukarıda ki gibi bu sefer de searh_page.dart dosyasında oluşan SearchPage sınıfına gider
                    MaterialPageRoute(  
                      builder: (context) => SearchPage(), 
                    ),
                  );
                },
              ),

              //? ayarlar list tile kısmı
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(      //* aynı şekilde ayarlar sayfasına gider
                      builder: (context) => SettingsPage(), 
                    ),
                  );
                },
              ),
              const Spacer(),

              // ÇIKIŞ YAP ListTile'ı
              MyDrawerTile(
                title: "ÇIKIŞ YAP",
                icon: Icons.logout,
                // logOut fonksiyonuna context parametresini geçiriyoruz
                //* tıklandığında logOut fonksiyonu devreye girsin ve kullanıcı çıkış yapabilsin istiyoruz.
                onTap: () => logOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
