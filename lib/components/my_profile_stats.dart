//* post ---- followers ----- following 

import 'package:flutter/material.dart';

//* kişinin profilinde neler olduğunu gösteriyor.  



class MyProfileStats extends StatelessWidget {
  
  //* takip edilen takipçiler tıklama gibi tanımları yaptık
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;



  const MyProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {

    var textStyleForCount = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.inversePrimary
    );

    var textStyleForText = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
          //* postların olduğu br kutucuk 
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString(),
                style: textStyleForCount), 
                Text("Posts",style: textStyleForText)
              ],
            ),
          ),
      
      
      
          //* followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followerCount.toString(),
                style: textStyleForCount),
                Text("Followers",style: textStyleForText)
              ],
            ),
          ),
      
      
      
      
          //* following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(),
                style: textStyleForCount),
                Text("Following",style: textStyleForText)
              ],
            ),
          )
        ],
      ),
    );
  }
}