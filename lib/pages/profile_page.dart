import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_bio_box.dart';
import 'package:twitter_clone_app/components/my_follow_button.dart';
import 'package:twitter_clone_app/components/my_input_alert_box.dart';
import 'package:twitter_clone_app/components/my_post_tile.dart';
import 'package:twitter_clone_app/components/my_profile_stats.dart';
import 'package:twitter_clone_app/helper/navigate_page.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/pages/follow_list_page.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';
import 'package:twitter_clone_app/pages/chat_screen.dart'; // ChatScreen sayfasını import edin.
import 'package:twitter_clone_app/components/my_message_button.dart'; // Mesaj Gönder Butonunu import ettik.

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();
  final bioTextController = TextEditingController();
  bool _isloading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);
    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);
    _isFollowing = databaseProvider.isFollowing(widget.uid);
    
    if (user != null) {
      bioTextController.text = user!.bio;
    }

    setState(() {
      _isloading = false;
    });
  }

  void _showEditBioBox() {
    bioTextController.text = user?.bio ?? '';
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: bioTextController,
        hintText: "Bio düzenle...",
        onPressed: saveBio,
        onPressedText: "Kaydet"
      ),
    );
  }

  Future<void> saveBio() async {
    setState(() {
      _isloading = true;
    });

    await databaseProvider.updateBio(bioTextController.text);
    await loadUser();

    setState(() {
      _isloading = false;
    });
  }

  Future<void> toggleFollow() async {
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Takibi Bırak"),
          content: Text("Takibi bırakmak istediğine emin misin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal et")
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await databaseProvider.unfollowUser(widget.uid);
              },
              child: Text("Evet")
            ),
          ],
        )
      );
    } else {
      await databaseProvider.followUser(widget.uid);
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);
    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    _isFollowing = listeningProvider.isFollowing(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isloading ? '' : user!.name),
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () => goHomePage(context),
          icon: Icon(Icons.arrow_back)
        ),
      ),
      body: ListView(
        children: [
          // Kullanıcı bilgileri (isim, username vb.)
          Center(
            child: Text(
              _isloading ? '' : '@${user!.username}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 25),
          
          // İnsan ikonu
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Post, Followers, Following butonları
          MyProfileStats(
            postCount: allUserPosts.length,
            followerCount: followerCount,
            followingCount: followingCount,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FollowListPage(uid: widget.uid))),
          ),
          
          const SizedBox(height: 25),

          // Takip Et ve Mesaj Gönder butonları (yan yana)
          if (user != null && user!.uid != currentUserId)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Takip Et Butonu
                  MyFollowButton(
                    onPressed: toggleFollow,
                    isFollowing: _isFollowing,
                  ),
                  
                  // Mesaj Gönder Butonu
                    // Butonlar arasında biraz mesafe bırakıyoruz
                  MyMessageButton(  // Mesaj Gönder butonunu ekliyoruz
                    onPressed: () {
                      // Mesajlaşma ekranına gitmek için ChatScreen sayfasını aç
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientUid: user!.uid,
                            recipientName: user!.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          
          // Bio kısmı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bio", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                if (user != null && user!.uid == currentUserId)
                  GestureDetector(
                    onTap: _showEditBioBox,
                    child: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MybioBox(text: _isloading ? '...' : user!.bio),

          // Postlar kısmı
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: Text("Posts", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          allUserPosts.isEmpty 
            ? const Center(child: Text("Henüz gönderi yok"))
            : ListView.builder(
                itemCount: allUserPosts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final post = allUserPosts[index];
                  return MyPostTile(
                    post: post,
                    onUserTap: () => goUserPage(context, post.uid),
                    onPostTap: () => goPostPage(context, post),
                  );
                }
              ),
        ],
      ),
    );
  }
}
