import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_user_tile.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    //* provider
    final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Kişileri ara ...",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),
            border: InputBorder.none,
          ),

          //* search will begin after each new characakter has been type 
          onChanged: (value){
            
            //* search users
            if(value.isNotEmpty){
              databaseProvider.searchUser(value);
            }

            //* clear results
            else{
              databaseProvider.searchUser("");
            }
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,

      //* body 
      body:listeningProvider.searchResult.isEmpty?
      
      //* no users found ..listeninProvider
      Center(
        child: Text( "Kullanıcı bulunamadı"),
      )
      :

      //* user found!
      ListView.builder(
        itemCount: listeningProvider.searchResult.length,
        itemBuilder: (context,index){
          //* get each user search result 
          final user = listeningProvider.searchResult[index];

          //* return as a user tile 
          return MyUserTile(user: user);
        }
      )
      
      ,
    );
  }
}