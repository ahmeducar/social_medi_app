import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_settings_tile.dart';
import 'package:twitter_clone_app/helper/navigate_page.dart';
import 'package:twitter_clone_app/themes/theme.provider.dart';


/*
//?Dark mode 
//!bloklanmış kullanıcılar 
//?hesap ayarları



?*/
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("S E T T I N G S"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //? Dark mod 
          MySettingsTile(
            title: "Dark Mod",
            action: CupertinoSwitch(
              onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              value:Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
              ),
            ),

          //* bloklanmış kullanıcılar tile 
          MySettingsTile(
            title: "Blocklanmış Kullanıcılar",
            action: IconButton(
              onPressed: () => goBlockedUsersPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary
                ),
            ),
          ),

          //! hesap ayarları tile 
          MySettingsTile
          (
            title: "Hesap Ayarları",
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary
                ),
            ),
          )
        ],
      ),
    );
  }
}
