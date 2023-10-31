// import 'dart:io';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:fast_image_resizer/fast_image_resizer.dart';

import 'app.dart';

const emojis = [
  "938503760811012106",
  "859798399540264960",
  "1063489915674964058",
  "636305060187602965"
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
      url: "https://hlencppvpaasdhvworuq.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsZW5jcHB2cGFhc2RodndvcnVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTc3MjA4ODYsImV4cCI6MjAxMzI5Njg4Nn0.eRrWPjuiiPdXLhT1BpLyotlZA5hASZm_3HbEKhJNtCg");

  runApp(const MimeApp());
}


// class MimeApp extends StatelessWidget {
//   const MimeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: "a"),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     var currentUser = supabase.auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               currentUser == null
//                   ? 'Not logged in'
//                   : "Logged In, id is ${currentUser.userMetadata}",
//             ),
//             FilledButton(
//               onPressed: () {
//                 if (currentUser != null) {
//                   supabase.auth.signOut();
//                 }
//               },
//               child: const Text("Log Out"),
//             ),
//             FilledButton(
//               onPressed: () async {
//                 // Insert into db
//                 var x = await supabase.from("assets").update({
//                   "animated": true,
//                 }).eq(
//                   "asset_id",
//                   1063489915674964058,
//                 );
//                 print(x);
//               },
//               child: const Text("Insert"),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: auth,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Future auth() async {
//     if (supabase.auth.currentUser == null) {
//       var x = await supabase.auth.signInWithOAuth(Provider.discord);
//       print(x);
//     } else {
//       print(supabase.auth.currentSession);
//       print(supabase.auth.currentUser);
//     }
//   }

//   Future emoji() async {
//     var applicationDocumentsDirectory =
//         await getApplicationDocumentsDirectory();
//     var stickersDirectory =
//         Directory('${applicationDocumentsDirectory.path}/stickers');
//     await stickersDirectory.create(recursive: true);

//     final dio = Dio();
//     final downloads = <Future>[];

//     emojis.forEach((emojiId) {
//       downloads.add(
//         dio.download(
//           "https://cdn.discordapp.com/emojis/$emojiId.png",
//           '${stickersDirectory.path}/$emojiId.png',
//         ),
//       );
//     });

//     await Future.wait(downloads);

//     final WhatsappStickersHandler _whatsappStickersHandler =
//         WhatsappStickersHandler();

//     Map<String, List<String>> stickers = <String, List<String>>{};
//     final rawImage = await rootBundle.load('assets/mime.png');
//     final bytes = await resizeImage(Uint8List.view(rawImage.buffer),
//         width: 96, height: 96);

//     // Write bytes to file
//     final file = File('${stickersDirectory.path}/mime.png');
//     await file.writeAsBytes(bytes!.buffer.asInt8List(), flush: true);

//     for (var emojiId in emojis) {
//       final imageBytes =
//           await File('${stickersDirectory.path}/$emojiId.png').readAsBytes();

//       final bytes = await resizeImage(imageBytes, width: 512, height: 512);

//       final bytesList = bytes!.buffer.asUint8List();

//       var result = await FlutterImageCompress.compressWithList(bytesList,
//           format: CompressFormat.webp);
//       // Write bytes to file
//       final file = File('${stickersDirectory.path}/$emojiId.webp');
//       await file.writeAsBytes(result, flush: true);

//       stickers[WhatsappStickerImageHandler.fromFile(
//               "${stickersDirectory.path}/$emojiId.webp")
//           .path] = ["🤓"];
//     }

//     try {
//       await _whatsappStickersHandler.addStickerPack(
//         "testStickers",
//         "Test Stickers",
//         "Chiggy",
//         WhatsappStickerImageHandler.fromFile(file.path).path,
//         "",
//         "",
//         "",
//         false,
//         stickers,
//       );
//     } on Exception catch (e) {
//       print(e);
//     }
//   }

//   // Future myFork() async {
//   //   var applicationDocumentsDirectory =
//   //       await getApplicationDocumentsDirectory();
//   //   var stickersDirectory =
//   //       Directory('${applicationDocumentsDirectory.path}/stickers');
//   //   await stickersDirectory.create(recursive: true);

//   //   // Resize tray image png and save
//   //   final rawImage = await rootBundle.load('assets/mime.png');
//   //   final bytes = await resizeImage(Uint8List.view(rawImage.buffer),
//   //       width: 96, height: 96);
//   //   final file = File('${stickersDirectory.path}/mime.png');
//   //   await file.writeAsBytes(bytes!.buffer.asInt8List(), flush: true);

//   //   final dio = Dio();
//   //   final downloads = <Future>[];

//   //   emojis.forEach((emojiId) {
//   //     downloads.add(
//   //       dio.download(
//   //         "https://cdn.discordapp.com/emojis/$emojiId.png",
//   //         '${stickersDirectory.path}/$emojiId.png',
//   //       ),
//   //     );
//   //   });

//   //   await Future.wait(downloads);

//   //   var stickerPack = WhatsappStickers(
//   //     identifier: 'chiggyTestStickerPlus',
//   //     name: 'Chiggy Test Stickers Plus',
//   //     publisher: 'Chiggy',
//   //     trayImageFileName:
//   //         WhatsappStickerImage.fromFile('${stickersDirectory.path}/mime.png'),
//   //     publisherWebsite: '',
//   //     privacyPolicyWebsite: '',
//   //     licenseAgreementWebsite: '',
//   //   );

//   //   for (var emojiId in emojis) {
//   //     final imageBytes =
//   //         await File('${stickersDirectory.path}/$emojiId.png').readAsBytes();

//   //     final bytes = await resizeImage(imageBytes, width: 512, height: 512);
//   //     final bytesList = bytes!.buffer.asUint8List();
//   //     File('${stickersDirectory.path}/$emojiId-resized.png')
//   //         .writeAsBytes(bytesList, flush: true);

//   //     var result = await FlutterImageCompress.compressWithList(
//   //       bytesList,
//   //       format: CompressFormat.webp,
//   //     );
//   //     // Write bytes to file
//   //     final file = File('${stickersDirectory.path}/$emojiId.webp');
//   //     await file.writeAsBytes(result, flush: true);

//   //     stickerPack.addSticker(
//   //         WhatsappStickerImage.fromFile(
//   //             '${stickersDirectory.path}/$emojiId.webp'),
//   //         ["🤓"]);
//   //   }

//   //   try {
//   //     await stickerPack.sendToWhatsApp();
//   //   } on WhatsappStickersException catch (e) {
//   //     print(e.cause);
//   //   }
//   // }

//   // Future installFromRemote() async {
//   //   var applicationDocumentsDirectory =
//   //       await getApplicationDocumentsDirectory();
//   //   var stickersDirectory =
//   //       Directory('${applicationDocumentsDirectory.path}/stickers');
//   //   await stickersDirectory.create(recursive: true);

//   //   // final dio = Dio();
//   //   // final downloads = <Future>[];

//   //   // emojis.forEach((emojiId) {
//   //   //   downloads.add(
//   //   //     dio.download(
//   //   //       "https://cdn.discordapp.com/emojis/$emojiId.webp",
//   //   //       '${stickersDirectory.path}/$emojiId.webp',
//   //   //     ),
//   //   //   );
//   //   // });

//   //   // await Future.wait(downloads);

//   //   final WhatsappStickersHandler _whatsappStickersHandler =
//   //       WhatsappStickersHandler();

//   //   Map<String, List<String>> stickers = <String, List<String>>{};
//   //   final rawImage = await rootBundle.load('assets/mime.png');
//   //   final bytes =
//   //       await resizeImage(Uint8List.view(rawImage.buffer), width: 512);

//   //   var result = await FlutterImageCompress.compressWithList(
//   //     bytes!.buffer.asUint8List(),
//   //   );
//   //   // Write bytes to file
//   //   final file = File('${stickersDirectory.path}/mime.webp');
//   //   await file.writeAsBytes(result, flush: true);

//   //   await File('${stickersDirectory.path}/mime.png')
//   //       .writeAsBytes(rawImage.buffer.asInt8List(), flush: true);

//   //   stickers[WhatsappStickerImageHandler.fromFile(file.path).path] = [];

//   //   // for (var emojiId in emojis) {
//   //   //   stickers[WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/$emojiId.webp").path] = [];
//   //   // }

//   //   try {
//   //     await _whatsappStickersHandler.addStickerPack(
//   //       "testStickers",
//   //       "Test Stickers",
//   //       "Chiggy",
//   //       '${stickersDirectory.path}/mime.png',
//   //       "",
//   //       "",
//   //       "",
//   //       false,
//   //       stickers,
//   //     );
//   //   } on WhatsappStickersException catch (e) {
//   //     print(e.cause);
//   //   }
//   // }
// }
