import 'package:firetest/pages/tabs/handOperate.dart';
import 'package:flutter/cupertino.dart'; //IOS跳转风格
// import 'package:flutter/material.dart';

Map routes = {
  "/handoperate": (context) => const HandOperatePage(),
};

//配置 onGenerateRoute 固定写法
//中间件，可做权限判断
var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name; //
  final Function? pageContentBuilder =
      routes[name]; //  Function = (contxt) { return const NewsPage()}

  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = CupertinoPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          CupertinoPageRoute(builder: (context) => pageContentBuilder(context));

      return route;
    }
  }
  return null;
};
