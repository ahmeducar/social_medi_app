import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_drawer.dart';
import 'package:twitter_clone_app/components/my_input_alert_box.dart';
import 'package:twitter_clone_app/components/my_post_tile.dart';
import 'package:twitter_clone_app/helper/navigate_page.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override     
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

  final _messageController = TextEditingController();

  //* on startup
  @override
  void initState() {
    super.initState();
    loadAllPosts(); // Load posts on page load
  }

  //* load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  //* open dialog box for new post
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _messageController,
        hintText: "Aklında ne var",
        onPressed: () async {
          await postMessage(_messageController.text);
        },
        onPressedText: "Gönder"
      )
    );
  }

  //? user wants to post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message); // Post the message
    await loadAllPosts(); // Reload the posts after posting
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: For you and Following
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 40),
            child: const Text('A N A S A Y F A'),
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(text: 'Senin için'),
              Tab(text: 'Takip Edilenler'),
            ]
          ),
        ),
      
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),

        //* list of all posts
        body: TabBarView(
          children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
            
          ],
        
        ),
      ),
    );
  }
  
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
      ? Center(child: Text("Hiçbir şey yok .."))
      : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return MyPostTile(
              post: post,
              onUserTap: () => goUserPage(context, post.uid),
              onPostTap: () => goPostPage(context, post)
            );
          },
        );
  }   
}
