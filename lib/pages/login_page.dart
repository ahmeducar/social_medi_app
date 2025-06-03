import 'package:flutter/material.dart';
import 'package:twitter_clone_app/components/my_button.dart';
import 'package:twitter_clone_app/components/my_loading_circle.dart';
import 'package:twitter_clone_app/components/my_text_field.dart';
import 'package:twitter_clone_app/pages/home_page.dart';
import 'package:twitter_clone_app/pages/register_page.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;  // Bu, "Üye Ol" butonunun tıklanma işlemi için

  const LoginPage({
    super.key,
    this.onTap,  // onTap opsiyonel hale getirilmiş
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

void login() async {
  showLoadingCircle(context); // Loading circle gösteriliyor

  try {
    // Email ve şifreyle giriş yapılıyor
    await _auth.loginEmailPassword(emailController.text, pwController.text);
    
    if (mounted) hideLoadingCircle(context); // Eğer widget hala mount edilirse, loading circle gizleniyor

    // Giriş başarılıysa ana sayfaya yönlendiriyoruz
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Ana sayfaya yönlendiriliyor
      );
    }
  } catch (e) {
    if (mounted) hideLoadingCircle(context); // Hata durumunda loading circle gizleniyor

    // Şifre hatası için özel kontrol ekleniyor
    String errorMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";

    if (e.toString().contains("wrong-password")) {
      errorMessage = "Şifre yanlış, lütfen tekrar deneyin.";
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorMessage), // Hata mesajı gösteriliyor
        ),
      );
    }

    debugPrint(e.toString()); // Hata konsola yazdırılıyor
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView( // ScrollView eklendi
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  //? LOGO KOYULACAK
                  Icon(
                    Icons.lock_open_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 40),
                  //!HOŞGELDİN MESAJI
                  Text(
                    "Hoşgeldin, Seni özledik",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  //* EMAİL KUTUCUĞU
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail Giriniz",
                    obscureText: false,
                  ),
                  const SizedBox(height: 8),

                  //? ŞİFRE KUTUCUĞU
                  MyTextField(
                    controller: pwController,
                    hintText: "Şifre Giriniz",
                    obscureText: true,
                  ),

                  //! ŞİFRENİ Mİ UNUTTUN KISMI
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Şifreni mi unuttun ?"),
                    ),
                  ),
                  const SizedBox(height: 30),

                  //* GİRİŞ YAP BUTONU
                  MyButton(onTap: login, text: "Giriş Yap"),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Üye değil misin ?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "Hemen üye ol" butonuna tıklandığında RegisterPage'e yönlendiriyoruz
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(
                                onTap: () {},  // onTap boş bırakılabilir
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Hemen üye ol",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
