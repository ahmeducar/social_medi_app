import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_input_alert_box.dart';
import 'package:twitter_clone_app/helper/time_formatter.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';


//* postların durumunu izlemek için değişecekleri için StatefulWidget ile oluşturulmuş bir sınıf
class MyPostTile extends StatefulWidget {

  //* post için ve onlara tıklamak için oluşturulmuş tanımlamalar
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  
  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  
  //* bunlara sonradan bakıcam provider ile state management yani durum yönetimi ile alakalı 
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

  //* Mesaje raporlandı mı veya blocklandı mı diye bir bool tanımlıyoruz başlangıçta false olacak
  bool _showReportMessage = false;
  bool _showBlockMessage = false;

  //* Önemli Not: initState sadece ilk oluşturulma sırasında çalışır. Widget her yeniden çizildiğinde, bu metod tekrar çalışmaz.
  @override
  void initState() {
    super.initState();

    //* yorumları yükleme fonksiyonu çağırılıyor.
    _loadComments();
  }

  //* fonksiyon ile posta atılan beğeni bir beğeni atıldı ve çekildi ona göre beğeni sayısı da gözükecek
  void _toggleLikePost() async {
    try {                         //* toggleLike fonksiyonu ile
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //* nasıl ki bir email veya şifre yazarken TextEditingController kullanılıyorsa yorum için de bir tanımlama yapıyoruz
  final _commentsController = TextEditingController();

  //* yorumları görebilmek için bir fonksiyon oluşturuyoruz
  void _openNewCommentBox() {

    //* diyalog gösteren widget
    showDialog(
        context: context,     //* MyInputAlertBox sınıfından türüyor text editingController var, hintText ve onPressed var zorunlu
        builder: (context) => MyInputAlertBox(
            textController: _commentsController,
            //* içerisinde bir yorum yaz diyecek tıklandığında gidecek
            hintText: 'Bir yorum yaz',
            //* tıklandığında ne oluyor
            onPressed: () async {
              //* yazıldı ve ona tıklandıysa bir yorum ekleniyor
              await _addComment();
            },
            onPressedText: "Post"));
  }

  //* bu da bizim Future ile yani bir şeylerin sonucu ile dönen asenkron fonksiyon modeli ile oluşmuş bir yorum ekleme fonksiyonudur.
  Future<void> _addComment() async {
    if (_commentsController.text.trim().isEmpty) return;
    try {
      //* yukarıda boşluk varsa o trim ile boşlukları siliyoruz tamamen boşsa return ile fonksiyon sonlandırıldı demek
      //* eğer bir şeyler yazmışsa orası boş değilse bu fonksiyon ile databaseProvider.addComment ile bu fonksiyonu biz ayarladık
      //* addComment ile yorum atılır.
      await databaseProvider.addComment(widget.post.id, _commentsController.text.trim());
      _commentsController.clear();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //* yorumları yüklemek için databaseProvider ile loadComments fonksiyonu kullanarak yorumlara ulaşırız.
  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  //* SHOW OPTİONSSSS

  //* showOpsions seçeneği ile postlara ya da yorumlara ne yapabileceğimiz görüyoruz örneğin silmek reportlamak gibi
  void _showOptions() {

    //* AuthService sınıfından uygulamaya giren kişiyi currenUid ile aldık oraya verdik
    String currenUid = AuthService().getCurrentUid();

    //* bu post uygulamaya giren kullanıcının postumu onun için isOwnPost ile tanımladık true ile silebilecek 
    //* false olduğunda sil butonu gözükmeyecek
    final bool isOwnPost = widget.post.uid == currenUid;

    //* burada da if koşulu ile post kişinin kendisinin mi true ise yani kendininse sil seçeneği çıkıyor 
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                if (isOwnPost)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Sil"),
                    onTap: () async {
                      Navigator.pop(context);
                      await databaseProvider.deletePost(widget.post.id);
                    },
                  )
                //* kendinin değil başkasınınsa report ve bloke user yani seçenekleri gelecek
                else
                  ...{  //* iconu başlığı ve tıklandığında ne olacağı belirtiliyor
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: const Text("Report"),
                      onTap: () async {
                        Navigator.pop(context);
                        await Future.delayed(Duration(milliseconds: 200));
                        //* bu fonksiyonlar hep başka yerden gelme 
                        _reportPostConfirmationBox();
                      },
                    ),
                    //* iconu başlığı ve tıklandığında ne olacağı belirtiliyor
                    ListTile(
                      leading: const Icon(Icons.block),
                      title: const Text("Block User"),
                      onTap: () {
                        Navigator.pop(context);

                        //* bu fonksiyonlar hep başka yerden gelme 
                        _blockUserConfirmationBox();
                      },
                    ),
                  },
                //* else içinden çıktık kişinin kendisininse sil ve iptal kısmı var silersek pop ile geri dönüyoruz.
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text("İptal"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        });
  }

  //* Raporlama fonksiyonu oluşturuyoruz
  void _reportPostConfirmationBox() {
    //* yine bir diyalog kutucuğu görüyoruz
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //* show diyalog ile bir AlertDialog widgeti getiriyoruz ve o da title content ve actionsa sahip.
        title: const Text("Rapor Mesaj"),
        content: const Text("Emin misin? Bu mesajı raporlamak istiyor musun?"),
        actions: [
          TextButton(
            child: Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Raporla"),
            onPressed: () async {
              Navigator.pop(context);

              //* Report işlemi reportUser bizim kendi oluşturduğumuz fonksiyon
              await databaseProvider.reportUser(widget.post.id, widget.post.uid);

              if (mounted) {
                //* Raporlama işlemi tamamlandıktan sonra sadece rapor mesajını göster
                setState(() {
                  _showReportMessage = true;
                });

                // Rapor mesajını 3 saniye sonra gizle
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showReportMessage = false;
                    });
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  //* Kullanıcıyı blocklama işlemi
  void _blockUserConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kullanıcıyı Blockla ?"),
        content: const Text("Emin misin ? Bu kullanıcıyı blocklamak istiyor musun ?"),
        actions: [
          TextButton(
            child: Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Blockla"),
            onPressed: () async {
              Navigator.pop(context);

              //* Kullanıcıyı blocklama işlemi
              await databaseProvider.blockUser(widget.post.uid);

              if (mounted) {
                //* Blocklama işlemi tamamlandıktan sonra sadece block mesajını göster
                setState(() {
                  _showBlockMessage = true;
                });

                //* Block mesajını 3 saniye sonra gizle
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showBlockMessage = false;
                    });
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //* bu fonksiyonları databaseProvider.dart dosyasında anlayacağım
    bool likedByCurrentUser = listeningProvider.isPostLikedByCurrentUser(widget.post.id);
    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        widget.post.name,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text('@${widget.post.username}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showOptions,
                        child: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.post.message, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                const SizedBox(height: 20),
                Row(
                  
                  children: [
                    
                    SizedBox(
                      
                      width: 90,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleLikePost,
                            child: likedByCurrentUser
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : Icon(Icons.favorite_border, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            likeCount != 0 ? likeCount.toString() : '',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      
                      children: [
                        GestureDetector(
                          onTap: _openNewCommentBox,
                          child: Icon(Icons.comment, color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          commentCount != 0 ? commentCount.toString() : '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),

                    const Spacer(),
                    
                    //* timestamp
                    Text(formatTimestamp(widget.post.timestamp))

                    
                  ], 
                ),
              ],
            ),
          ),
          // Mesajlar sırasıyla gösterilecek
          if (_showReportMessage) _buildMessage("Mesaj Raporlandı", 10),
          if (_showBlockMessage && !_showReportMessage) _buildMessage("Kullanıcı Blocklandı", 50),
        ],
      ),
    );
  }

  Widget _buildMessage(String message, double bottom) {
    return Positioned(
      bottom: bottom, // Mesajı ekranın altına daha belirgin bir mesafe ile konumlandırıyoruz
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
