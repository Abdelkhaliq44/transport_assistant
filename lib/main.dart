import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transport_assistant/ui_pages/home_page.dart';
import 'package:transport_assistant/ui_pages/line_page.dart';
import 'package:transport_assistant/ui_pages/opshns_page.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await   Firebase.initializeApp();
  runApp(   EasyLocalization(
    supportedLocales:  [Locale('en'), Locale('ar'), Locale('fr')],
    path: 'assets/lang',
    fallbackLocale:  Locale('en'),
    child:  MyApp(),
  ),);

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  int _slctedindex =0;
  final PageController _pageController = PageController();
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  ThemeMode _themeMode = ThemeMode.light;
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  void _goToMap(double lat, double lng, String name) {
    _onchingde(0); // الانتقال إلى الصفحة الرئيسية
    Future.delayed(const Duration(milliseconds: 2000), () {
      _homeKey.currentState?.moveCameraTo(lat, lng, name);
    });
  }
  void _onchingde(int indxe){
    setState(() {
      _slctedindex = indxe;


    });
    _pageController.animateToPage(
      indxe,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final List<Widget>screns=<Widget>[

      HomePage(key: _homeKey,onLocaleChanged: changeLocale),
      LinePage(onGoToMap:()  => _onchingde(0),),
      Optionspage(onGoToMap: _goToMap,
        onThemeChanged: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),

    ];
    return Builder(
      builder: (context) {
        return SafeArea(
          child: MaterialApp(

            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            themeMode: _themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            title: 'Transport_Assistant',
            locale:context.locale,
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body:PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index){
                  setState(() {
                    _slctedindex=index;
                  });

                },
                children: screns,
              ),
              bottomNavigationBar:Builder(
                builder: (context) {
                  return BottomNavigationBar(
                    backgroundColor:
                    _themeMode == ThemeMode.dark ? Colors.black54 : const Color(0xff4B7BFF),
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Color(0xffFFA726),
                    currentIndex: _slctedindex,
                    selectedFontSize: 20,
                    unselectedFontSize: 16,
                    onTap:_onchingde,
                    items: [
                      BottomNavigationBarItem(icon: Icon(Icons.home_filled),label: 'home'.tr()),
                      BottomNavigationBarItem(icon: Icon(Icons.map_outlined),label: 'path'.tr()),
                      BottomNavigationBarItem(icon: Icon(Icons.menu_outlined),label: 'options'.tr()),
                    ],
                  );
                }
              ),

            ),
          ),
        );
      }
    );
  }
}