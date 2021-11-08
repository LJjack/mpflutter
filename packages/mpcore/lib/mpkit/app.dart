part of 'mpkit.dart';

class MPApp extends StatelessWidget {
  final String? title;
  final Color? color;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final List<NavigatorObserver> navigatorObservers;
  final double? maxWidth;

  MPApp({
    this.title,
    this.color,
    required this.routes,
    this.onGenerateRoute,
    required this.navigatorObservers,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title ?? '',
      color: color ?? Colors.blue,
      builder: (context, widget) {
        return widget ?? Container();
      },
      routes: routes,
      navigatorObservers: navigatorObservers,
      onGenerateRoute: (settings) {
        return onGenerateRoute?.call(settings) ??
            MPPageRoute(builder: (context) {
              final routeBuilder = routes[settings.name];
              if (routeBuilder != null) {
                return routeBuilder(context);
              } else {
                return Container();
              }
            });
      },
      onGenerateInitialRoutes: (_) {
        final routeName = MPNavigatorObserver.instance.initialRoute;
        final routeParams = MPNavigatorObserver.instance.initialParams;
        final routeSetting =
            RouteSettings(name: routeName, arguments: routeParams);
        return [
          onGenerateRoute?.call(routeSetting) ??
              MPPageRoute(
                builder: (context) {
                  final routeBuilder = routes[routeName];
                  if (routeBuilder != null) {
                    return routeBuilder(context);
                  } else {
                    return Container();
                  }
                },
                settings: routeSetting,
              )
        ];
      },
    );
  }
}
