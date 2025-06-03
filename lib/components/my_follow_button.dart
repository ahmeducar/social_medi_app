//* burası sadece Follow yani takip et butonu için oluşturulmuş.

import 'package:flutter/material.dart';

//* sadece bir buton olacak ve buton aynı kalacak o yüzden MyFollowButton sınıfı stateless ile oluşturulmuş.
class MyFollowButton extends StatelessWidget {

  //* onPressed ismi verdik tıklandığında bu çağıralacak
  final void Function()? onPressed;
  
  //*bunu kişi takip ediliyor mu o yüzden bu tanımlama yapıldı  
  final bool isFollowing;

  //* burada da required ile vemeliyiz
  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: MaterialButton(
          padding: EdgeInsets.all(16),
          onPressed: onPressed,
          //*rengi şu şekilde takip ediliyorsa yani true ise gri olacak, : takip edilmiyorsa mavi renkli bir kutucuk takip et yazacak onda
          color:isFollowing? Theme.of(context).colorScheme.primary : Colors.blue,
          child: Text(
              //* içinde ki yazıda burada yazıyor true olduğunda yani takip ediliyorsa Takibi bırak yazsın, değilse takip et yazsın.
              isFollowing? "Takibi Bırak" : "Takip Et",
              style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            )
            ),
        ),
      )
    );
  }
}