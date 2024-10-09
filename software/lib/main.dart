import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/screen/home_page.dart';
import 'business/bloc/setting_bloc.dart';
// import 'package:media_kit/media_kit.dart';              
// import 'package:media_kit_video/media_kit_video.dart';  
void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        routes: {'/': (context) => HomePage()},
      ),
    );
  }
}
