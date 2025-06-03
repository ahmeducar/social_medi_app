import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/models/message.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';
import 'package:intl/intl.dart'; //* intl paketini import ediyoruz

//* mesajlaşma kişilerin konuştuğu ekran her seferinde değiştiği için stateful widget kullanılır

class ChatScreen extends StatefulWidget {
  final String recipientUid; //* Sohbet edilen kişinin UID'si
  final String recipientName; //* Sohbet edilen kişinin adı

  //* required vermek zorundayız
  const ChatScreen({
    super.key,
    required this.recipientUid,
    required this.recipientName
  });

  @override
  ChatScreenState createState() => ChatScreenState(); // Burada _ChatScreenState yerine ChatScreenState kullanıyoruz
}

class ChatScreenState extends State<ChatScreen> {
  
  //* arada ki sohbeti tutan değişken _messageController değişkenine atanıyor.
  final TextEditingController _messageController = TextEditingController();

  //* Mesaj gönderme fonksiyonu _sendMessage fonksiyonu şimdi bu sayfada yazıldı ama 
  void _sendMessage() {

    //* message değişkenine atanır controllerda olan text 
    String message = _messageController.text.trim();

    //* boş değilse mesaj gönderilir ve controllerdeki text'in temizlenir.
    if (message.isNotEmpty) {
      //* database providerda olan sendMessage fonksiyonu ile 
      Provider.of<DatabaseProvider>(context, listen: false)
          .sendMessage(widget.recipientUid, message);
      _messageController.clear();
    }
  }

  //* Sohbet mesajlarını göstermek için StreamBuilder kullanmak
Widget _buildMessageList() {
  return StreamBuilder<List<Message>>(             //* getMessages database provider dart dosyasında 
    stream: Provider.of<DatabaseProvider>(context).getMessages(widget.recipientUid),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      final messages = snapshot.data!;
      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isSender = message.senderId == widget.recipientUid;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          // DateTime nesnesine dönüştürüp istediğimiz formatta yazdırıyoruz
            DateTime utcTime = message.timestamp.toDate();
            DateTime localTime = utcTime.add(Duration(hours: 3)); // 3 saat fark ekliyoruz

            // Zamanı istediğimiz formatta yazdırıyoruz
            String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(localTime);

          return ListTile(
            title: Align(
              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mesaj kutusunun tasarımı
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      // Dark Mode için
                      color: isDarkMode
                          ? (isSender ? Colors.blueAccent : Colors.grey[700])
                          // Light Mode için
                          : (isSender
                              ? Colors.blueAccent
                              : Colors.blueAccent), // Light mode'da gönderenin kutucuğu yeşil
                      borderRadius: BorderRadius.circular(12),
                      border: isDarkMode
                          ? null
                          : Border.all(color: Colors.grey), // Light Mode'da kenarlık ekleyelim
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(
                        color: Colors.white, // Gönderenin yazısı her iki modda beyaz olacak
                      ),
                    ),
                  ),
                  // Tarih ve saati göstermek için eklenen kısım
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white  // Dark Mode'da beyaz
                            : Colors.black, // Light Mode'da siyah
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Mesaj yaz...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
