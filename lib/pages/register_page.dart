import 'package:flutter/material.dart';
import 'package:twitter_clone_app/components/my_button.dart';
import 'package:twitter_clone_app/components/my_loading_circle.dart';
import 'package:twitter_clone_app/components/my_text_field.dart';
import 'package:twitter_clone_app/pages/login_page.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  
  final _auth = AuthService();
  final _db = DatabaseService();

  void register() async {
    if (pwController.text == confirmController.text) {
      showLoadingCircle(context);
      try {
        await _auth.registerEmailPassword(
          emailController.text,
          pwController.text
        );

        if (mounted) hideLoadingCircle(context);
        
        await _db.saveUserInfoInFirebase(
          name: nameController.text,
          email: emailController.text
        );
      } catch (e) {
        if (mounted) hideLoadingCircle(context);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Şifre Eşleşmiyor"),
        ),
      );
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
                    "Bir Hesap Açalım",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  MyTextField(
                    controller: nameController,
                    hintText: "İsim Giriniz",
                    obscureText: false,
                  ),
                  const SizedBox(height: 12),
                  //* EMAİL KUTUCUĞU
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail Giriniz",
                    obscureText: false,
                  ),
                  //? ŞİFRE KUTUCUĞU
                  const SizedBox(height: 12),
                  MyTextField(
                    controller: pwController,
                    hintText: "Şifre Giriniz",
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  MyTextField(
                    controller: confirmController,
                    hintText: "Şifreyi Tekrarlayiniz",
                    obscureText: true,
                  ),
                  const SizedBox(height: 60),
                  //* ÜYE OL BUTONU
                  MyButton(onTap: register, text: "Üye ol "),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Zaten üye misin ?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 30),
                      // "Giriş Yap" butonuna tıklandığında LoginPage'e yönlendirme
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Giriş Yap",
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
