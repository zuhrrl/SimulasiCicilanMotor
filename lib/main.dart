import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:simulasi_cicilan_motor/component/widget/bottom_bubble_navigation.dart';
import 'package:simulasi_cicilan_motor/constant/ads_code.dart';
import 'package:simulasi_cicilan_motor/constant/app_colors.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pageTitle = "Simulasi Cicilan";
  int _counter = 0;
  int currentIndex = 0;
  double _downPayment = 0;
  double _lamaCicilan = 0;
  double _cicilanPerbulan = 0;
  double _finalHarga = 0;
  double _hargaCashBarang = 0;
  double _hargaSebelumCicilan = 0;
  double _selisihHargaCicilan = 0;
  int timeCalculate = 0;

  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdReady = false;

  void changePage(int? index) {
    setState(() {
      currentIndex = index!;
      switch (currentIndex) {
        case 0:
          setState(() {
            pageTitle = "Simulasi Cicilan";
          });
          break;
        case 1:
          setState(() {
            pageTitle = "Simulasi Cicilan Motor";
          });
          break;
        case 2:
          setState(() {
            pageTitle = "Simulasi Cicilan Mobil";
          });
          break;
        case 3:
          setState(() {
            pageTitle = "Simulasi Cicilan Rumah";
          });
          break;
      }
    });
  }

  getFinalHargaBarangCicilan() {
    return _cicilanPerbulan * _lamaCicilan + _downPayment;
  }

  getSelisihHargaDenganKredit() {
    return _finalHarga - _hargaCashBarang;
  }

  void resetCalculator() {
    setState(() {
      _finalHarga = 0;
      _selisihHargaCicilan = 0;
    });
  }

  void splashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  bool _isInterstitialAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: admobInterstitialCode,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _loadInterstitialAd();
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitial() async {
    _interstitialAd!.show();
    timeCalculate = 0;
  }

  @override
  void initState() {
    splashScreen();
    _bannerAd = BannerAd(
      adUnitId: admobBannerCode,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _loadInterstitialAd();
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: mainColor,
        title: Text(pageTitle),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            Padding(
              child: SpinBox(
                value: 0,
                max: 999999999,
                onChanged: (value) {
                  _downPayment = value;
                  resetCalculator();
                },
                decoration: InputDecoration(labelText: 'Down Payment (Rupiah)'),
              ),
              padding: const EdgeInsets.all(16),
            ),
            Padding(
              child: SpinBox(
                value: 0,
                max: 999999999,
                onChanged: (value) {
                  _cicilanPerbulan = value;
                  resetCalculator();
                },
                decoration:
                    InputDecoration(labelText: 'Cicilan Perbulan (Rupiah)'),
              ),
              padding: const EdgeInsets.all(16),
            ),
            Padding(
              child: SpinBox(
                value: 0,
                max: 360,
                onChanged: (value) {
                  _lamaCicilan = value;
                  resetCalculator();
                },
                decoration: InputDecoration(labelText: 'Lama Cicilan (Bulan)'),
              ),
              padding: const EdgeInsets.all(16),
            ),
            Padding(
              child: SpinBox(
                value: 0,
                max: 999999999,
                onChanged: (value) {
                  _hargaCashBarang = value;
                  resetCalculator();
                },
                decoration:
                    InputDecoration(labelText: 'Harga Cash Barang (Rupiah)'),
              ),
              padding: const EdgeInsets.all(16),
            ),
            Container(
              width: 300,
              height: 32,
              child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: mainColor),
                  onPressed: () {
                    setState(() {
                      _finalHarga = getFinalHargaBarangCicilan();
                      if (_finalHarga > _hargaCashBarang) {
                        _selisihHargaCicilan = getSelisihHargaDenganKredit();
                        if (_isInterstitialAdReady && timeCalculate == 3)
                          showInterstitial();
                        timeCalculate += 1;
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Periksa Inputan Anda Kembali!'),
                            content: Text(
                                "Upss Jumlah dana setelah cicilan (Rp. $_finalHarga) kurang dari harga cash barang (Rp. $_hargaCashBarang)"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    });
                  },
                  child: Text(
                    "Kalkulasi Cicilan",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("Selisih Harga Dengan Kredit"),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Rp. $_selisihHargaCicilan",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffbf616a)),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("Harga Sesudah Kredit"),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Rp. $_finalHarga",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            if (_isBannerAdReady)
              Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
                ),
              )
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          exit(0);
        },
        child: Icon(Icons.exit_to_app),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        fabLocation: BubbleBottomBarFabLocation.end, //new
        hasNotch: true, //new
        hasInk: true, //new, gives a cute ink effect
        inkColor: Colors.black12, //optional, uses theme color if not specified
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: mainColor,
              icon: Icon(
                Icons.calculate,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.calculate,
                color: Colors.deepPurple,
              ),
              title: Text("Simulasi")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(
                Icons.motorcycle,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.motorcycle,
                color: Colors.deepPurple,
              ),
              title: Text("Cicilan Motor")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.car_rental,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.car_rental,
                color: Colors.indigo,
              ),
              title: Text("Cicilan Mobil")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.house,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.house,
                color: Colors.indigo,
              ),
              title: Text("Rumah"))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd!.dispose();
    super.dispose();
  }
}
