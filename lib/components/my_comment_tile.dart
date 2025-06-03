import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/helper/time_formatter.dart';
import 'package:twitter_clone_app/models/comment.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

//* yorumla alakalı bir durum olacak şuan tam anlamlandıramıyorum ama diğer kodlara baktığımda tam anlam getireceğim.

class MyCommentTile extends StatelessWidget {
  
  //* Comment sınıfından bir sabit tanımlanıyor comment; 
  final Comment comment;

  //* onUserTap parametresi ile bir tıklanma işlemi yapılabilir.
  final void Function()? onUserTap;

  //* burada da comment ve onUserTap için required kullanmak zorundayız
  const MyCommentTile({
    super.key,
    required this.comment,
    required this.onUserTap,
  });


    //* burada yorumlar için yani comment için neler yapılabir seçenekler olacak   
    void _showOptions(BuildContext context){
    
    //* currenUid ile AuthService sınıfından bir var olan kullanıcıyı bu değere atıyoruz.
    String currenUid = AuthService().getCurrentUid();
    
    //* yorumu yapan kişi uygulamada var olan kişi ise yani ben twitter kullanıyorum ve bir kişi gönderisine yorum yaptım bu yorum benim mi
    //* bu durum isOwnComment değişkenine atılıyor
    final bool isOwnComment = comment.uid == currenUid;

    //* bu widget kullanılacak yorumda aşağısında seçenekler olacak
    showModalBottomSheet(
      context: context,
      builder: (context){
        return SafeArea(
          child: Wrap(
            children: [
              
              //* bu yorum kullanıcıya ait ise şeklinde bir if koşulu var
              //* this post belongs to current user
              if(isOwnComment)

              //* delete comment button

              //* kişinin kendi yorumu ise bu listtile bakılacak 
              ListTile(
                leading: const Icon(Icons.delete),  //* leading tipik olarak bir circle avatar ya da icon alıyormuş 

                //* yorumu silmek için bir buton ekliyoruz
                title: const Text("Sil"), 
                onTap: ()async{
                  //* önce ki kere gel diyoruz
                  Navigator.pop(context);
                  
                //* silme işlemini buradan yapıyoruz deleteComment fonksiyonu yapıyor özellikle 
                  //* handle delete action
                  await Provider.of<DatabaseProvider>(
                    context, listen:false).deleteComment(comment.id,comment.postId);
                },
              )

              //* eğer kişi kendi yorumuna değil de başkasının yorumuna bakıyorsa eğer Report ve bloke kısımları olacak
              //* This comment does not belong to user
              else ...{
                ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Report"),
                onTap: (){
                  Navigator.pop(context);
                },
                ),
                ListTile(
                leading: const Icon(Icons.block),
                title: const Text("Block User"),
                onTap: (){
                  Navigator.pop(context);
                },
              )

              //* burası sile bastıktan sonra aşağıda bir iptal çıkacak iptale dokunursa kişi silme işlemi iptal edilir
              },
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("İptal"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        

        margin: EdgeInsets.symmetric(horizontal:25,vertical: 5),
      
        padding: EdgeInsets.all(20),
      
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onUserTap,
              child: Row(
                children: [
                  Icon(Icons.person,
                  color: Theme.of(context).colorScheme.primary
                  ),
              
                  const SizedBox(width: 10),
                    
                  Text(comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(width: 5),
              
                  Text('@${comment.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary
                    )
                  ),   
                const Spacer(),
                //* button more options: delete 
                
                GestureDetector(
                  onTap:()=> _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),  
            Text(
              comment.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 10),    
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Zamanı sağa hizalar
              children: [
                Text(
                  formatTimestamp(comment.timestamp),  // Zamanı gösteriyoruz
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ], 
        ),
      );
  }
}