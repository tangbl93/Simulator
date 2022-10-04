import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_switch/flutter_switch.dart';
// import 'package:flutter_switch/flutter_switch.dart';

void main() {
  runApp(const Simulator());
}

class Simulator extends StatelessWidget {
  const Simulator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '功德模拟器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimulatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> with TickerProviderStateMixin {

  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Widget> _children = [];
  final List<AnimationController> _controllers = [];

  bool _autoKnock = false;

  @override
  void dispose() {
    super.dispose();

    _audioPlayer.dispose();
    for (var element in _controllers) { element.dispose(); }
  }

  @override
  void initState() {
    super.initState();

    // 隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // 定时器
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_autoKnock) return;
      _playMp3();
    });
  }

  void _playMp3() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.seek(const Duration(seconds: 0));
    } else {
      await _audioPlayer.play(AssetSource("M001.mp3"));
    }
    _addGongDe();
  }

  void _addGongDe() async {
    var controller = AnimationController(
      duration: const Duration(milliseconds: 1618), 
      vsync: this,
    );

    var left = MediaQuery.of(context).size.width * 0.1;
    var top = 240 + _children.length*20;

    var child = AnimatedBuilder(
      animation: controller,
      builder: ((context, child) {
        return Positioned(
          left: left,
          top: top * (1-controller.value),
          child: Opacity(
            opacity: 1 - controller.value,
            child: child,
          ),
        );
      }),
      child: const Text("功德+1", style: TextStyle(
        fontSize: 36,
        fontFamily: "LongCang"
      )),
    );

    controller.addListener(() {
      if (controller.value == 1.0) {
        _children.remove(child);
        controller.dispose();
        _controllers.remove(controller);
      }

      setState(() {});
    });
    controller.forward();
    _controllers.add(controller);

    setState(() {
      _children.add(child);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _playMp3,
        child: Container(
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/A001.png'),
                    const SizedBox(height: 12),
                    FlutterSwitch(
                      width: 100.0,
                      height: 55.0,
                      toggleSize: 45.0,
                      value: _autoKnock,
                      borderRadius: 30.0,
                      padding: 2.0,
                      activeToggleColor: const Color(0xFFF9D86B),
                      inactiveToggleColor: const Color(0xFFACC0C5),
                      activeSwitchBorder: Border.all(
                        color: const Color(0xFFF9D86B),
                        width: 6.0,
                      ),
                      inactiveSwitchBorder: Border.all(
                        color: const Color(0xFFACC0C5),
                        width: 6.0,
                      ),
                      activeColor: const Color(0xFFF9D86B),
                      inactiveColor: const Color(0xFFACC0C5),
                      activeIcon: Image.asset("assets/800.jpeg"),
                      inactiveIcon: const Icon(Icons.unarchive),
                      onToggle: (val) {
                        setState(() {
                          _autoKnock = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              ..._children,
            ],
          ),
        ),
      ),
    );
  }
}