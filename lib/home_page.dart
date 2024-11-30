// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// final List<String> channels = [
//   "Gold",
//   "Silver",
//   "Platinum",
//   "Copper",
//   "Aluminum",
//   "BitCoin",
//   "Iron"
// ];
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final Set<String> _subscribedChannels = {};
//
//   void _subscribeToChannel(String channel) async {
//     setState(() {
//       _subscribedChannels.add(channel);
//     });
//     await FirebaseMessaging.instance.subscribeToTopic(channel);
//   }
//
//   void _unsubscribeFromChannel(String channel) async {
//     setState(() {
//       _subscribedChannels.remove(channel);
//     });
//     await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Channels"
//         ,
//           style: TextStyle(
//             color: Colors.white,
//           ),),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: channels.map((channel) {
//                 final bool isSubscribed = _subscribedChannels.contains(channel);
//                 return ListTile(
//                   title: Text(channel),
//                   trailing: TextButton(
//                     onPressed: () {
//                       isSubscribed
//                           ? _unsubscribeFromChannel(channel)
//                           : _subscribeToChannel(channel);
//                     },
//                     child: Text(
//                       isSubscribed ? "Unsubscribe" : "Subscribe",
//                       style: TextStyle(
//                         color: isSubscribed ? Colors.red : Colors.blue,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final List<String> channels = [
  "Gold",
  "Silver",
  "Platinum",
  "Copper",
  "Aluminum",
  "BitCoin",
  "Iron",
  "Zinc"
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Set<String> _subscribedChannels = {};

  void _subscribeToChannel(String channel) async {
    setState(() {
      _subscribedChannels.add(channel);
    });
    await FirebaseMessaging.instance.subscribeToTopic(channel);
  }

  void _unsubscribeFromChannel(String channel) async {
    setState(() {
      _subscribedChannels.remove(channel);
    });
    await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Channels",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF000000),
        elevation: 5,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                children: channels.map((channel) {
                  final bool isSubscribed = _subscribedChannels.contains(channel);
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      tileColor: isSubscribed
                          ? Colors.deepPurple[50]
                          : Colors.white,
                      title: Text(
                        channel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          isSubscribed
                              ? _unsubscribeFromChannel(channel)
                              : _subscribeToChannel(channel);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isSubscribed ? Color(0xFF697565) : Color(0xFFFF6500) ,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isSubscribed ? "Unsubscribe" : "Subscribe",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
