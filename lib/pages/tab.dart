
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Tabs extends StatefulWidget {
//   final int index;
//   const Tabs({super.key, this.index = 0});

//   @override
//   State<Tabs> createState() => _TabsState();
// }

// class _TabsState extends State<Tabs> {
//   late int _currentIndex;
//   GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
//   final List<Widget> _pages = [HomePage(), NewsPage(), SettingsPage()];

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _currentIndex = widget.index;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('HARDWARES'),
//       // ),
//       // drawer: Drawer(
//       //   width: 240,
//       //   child: Column(children: [
//       //     Row(
//       //       children: [
//       //         Expanded(
//       //             child: DrawerHeader(
//       //                 decoration: BoxDecoration(
//       //                     color: Colors.grey,
//       //                     image: DecorationImage(
//       //                         image: AssetImage("assets/images/userback.png"),
//       //                         fit: BoxFit.cover)),
//       //                 child: Column(
//       //                   children: [
//       //                     ListTile(
//       //                       leading: CircleAvatar(
//       //                         backgroundImage:
//       //                             AssetImage("assets/images/userimg.jpg"),
//       //                       ),
//       //                       title: const Text(
//       //                         "Mr.Lwd",
//       //                         style: TextStyle(color: Colors.white),
//       //                       ),
//       //                     )
//       //                   ],
//       //                 )))
//       //       ],
//       //     ),
//       //     ListTile(
//       //         leading: CircleAvatar(
//       //           child: Icon(Icons.people),
//       //         ),
//       //         title: TextButton(
//       //           child: const Text(
//       //             "项目关于",
//       //           ),
//       //           onPressed: () {},
//       //         )),
//       //     ListTile(
//       //         leading: CircleAvatar(
//       //           child: Icon(Icons.remove_red_eye),
//       //         ),
//       //         title: TextButton(
//       //           child: const Text(
//       //             "明亮切换",
//       //           ),
//       //           onPressed: () {
//       //             Get.bottomSheet(Container(
//       //               color: Get.isDarkMode ? Colors.black : Colors.white,
//       //               height: 200,
//       //               child: Column(
//       //                 children: [
//       //                   ListTile(
//       //                     leading: Icon(
//       //                       Icons.wb_sunny_outlined,
//       //                       color: Get.isDarkMode ? Colors.white : Colors.black,
//       //                     ),
//       //                     onTap: () {
//       //                       Get.changeTheme(ThemeData(
//       //                           brightness: Brightness.light,
//       //                           tabBarTheme:
//       //                               TabBarTheme(labelColor: Colors.black)));
//       //                       Get.back();
//       //                     },
//       //                     title: Text("白天模式",
//       //                         style: TextStyle(
//       //                             color: Get.isDarkMode
//       //                                 ? Colors.white
//       //                                 : Colors.black)),
//       //                   ),
//       //                   ListTile(
//       //                     leading: Icon(
//       //                       Icons.wb_sunny,
//       //                       color: Get.isDarkMode ? Colors.white : Colors.black,
//       //                     ),
//       //                     onTap: () {
//       //                       Get.changeTheme(ThemeData(
//       //                           brightness: Brightness.dark,
//       //                           iconTheme: IconThemeData(color: Colors.blue),
//       //                           tabBarTheme:
//       //                               TabBarTheme(labelColor: Colors.black),
//       //                           floatingActionButtonTheme:
//       //                               FloatingActionButtonThemeData(
//       //                                   backgroundColor: Colors.white,)));
//       //                       Get.back();
//       //                     },
//       //                     title: Text("夜晚模式",
//       //                         style: TextStyle(
//       //                             color: Get.isDarkMode
//       //                                 ? Colors.white
//       //                                 : Colors.black)),
//       //                   )
//       //                 ],
//       //               ),
//       //             ));
//       //           },
//       //         )),
//       //   ]),
//       // ),
//       body: _pages[_currentIndex],
//       bottomNavigationBar: CurvedNavigationBar(
//         key: _bottomNavigationKey,
//         index: 0,
//         height: 60.0,
//         items: const [
//           Icon(Icons.construction_outlined, size: 30),
//           Icon(Icons.newspaper, size: 30),
//           Icon(Icons.settings, size: 30),
//         ],
//         color: Colors.white,
//         buttonBackgroundColor: Colors.white,
//         backgroundColor: qingLiuColor,
//         animationCurve: Curves.easeInOut,
//         animationDuration: Duration(milliseconds: 500),
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         letIndexChange: (index) => true,
//       ),
//     );
//   }
// }
