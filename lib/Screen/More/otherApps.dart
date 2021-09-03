// // import 'package:admob_flutter/admob_flutter.dart';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:insaver/Utils/constants.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:auto_size_text/auto_size_text.dart';

// class OtherApps extends StatefulWidget {
//   @override
//   _OtherAppsState createState() => _OtherAppsState();
// }

// class _OtherAppsState extends State<OtherApps> {
//   FacebookNativeAd banner;

//   @override
//   void initState() {
//     super.initState();
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   loadBannerAd();
//   //   super.didChangeDependencies();
//   // }

//   // void loadBannerAd() {
//   //   banner = FacebookNativeAd(
//   //     placementId: bannerID,
//   //     adType: NativeAdType.NATIVE_BANNER_AD,
//   //     bannerAdSize: NativeBannerAdSize.HEIGHT_120,
//   //     height: 120,
//   //     buttonColor: color,
//   //     buttonBorderColor: color,
//   //     buttonTitleColor: Colors.white,
//   //     titleColor: Theme.of(context).accentColor,
//   //     descriptionColor: Colors.grey,
//   //     backgroundColor: Theme.of(context).primaryColor,
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "More Apps",
//           style: TextStyle(
//             color: Theme.of(context).accentColor,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Icon(Icons.arrow_back_ios),
//         ),
//         elevation: 0,
//         backgroundColor: Theme.of(context).primaryColor,
//         iconTheme: Theme.of(context).iconTheme,
//       ),
//       body: Stack(
//         children: [
//           FutureBuilder<QuerySnapshot>(
//             future: getData(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData && snapshot.data.docs.length != 0) {
//                 return Column(
//                   children: [
//                     SizedBox(height: 15),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         physics: BouncingScrollPhysics(),
//                         child: Column(
//                           children: [
//                             new ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: snapshot.data.docs.length,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (BuildContext context, int index) {
//                                 var x = snapshot.data.docs[index];
//                                 if (x == null) {
//                                   return Container();
//                                 } else {
//                                   return Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           width: double.infinity,
//                                           height: 120,
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               SizedBox(
//                                                 width: 120,
//                                                 height: 120,
//                                                 child: Container(
//                                                   child: ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             5),
//                                                     child: Image.network(
//                                                       x['image'],
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(width: 10),
//                                               Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.end,
//                                                 children: [
//                                                   SizedBox(
//                                                     width: size.width - 160,
//                                                     height: 50,
//                                                     child: AutoSizeText(
//                                                       x['name'],
//                                                       maxLines: 2,
//                                                       style: TextStyle(
//                                                           fontSize: 18),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       width: 120,
//                                                       height: 50,
//                                                       child: ElevatedButton(
//                                                         onPressed: () {
//                                                           _onOpen(x['url']);
//                                                         },
//                                                         child: Text(
//                                                           'Install',
//                                                           style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 18,
//                                                           ),
//                                                         ),
//                                                         style: ElevatedButton
//                                                             .styleFrom(
//                                                           primary:
//                                                               Color(0xFFf85343),
//                                                           minimumSize:
//                                                               Size(200, 50),
//                                                         ),
//                                                       )),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 5),
//                                       ],
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                             SizedBox(height: 200),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             },
//           ),
//           Positioned(
//             bottom: 0,
//             child: Container(
//               child: AdmobBanner(
//                 adUnitId: bannerID,
//                 adSize: AdmobBannerSize.FULL_BANNER,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _onOpen(String link) async {
//     if (await canLaunch(link)) {
//       await launch(link);
//     } else {
//       throw 'Could not launch $link';
//     }
//   }

//   Future<QuerySnapshot> getData() async {
//     await Firebase.initializeApp();
//     return await FirebaseFirestore.instance.collection('Apps').get();
//   }
// }
