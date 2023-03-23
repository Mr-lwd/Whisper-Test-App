import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:timelines/timelines.dart';
import 'package:whisper_flutter/whisper_flutter.dart';
import "package:cool_alert/cool_alert.dart";

const int tSampleRate = 16000;
// const int tSampleRate = 44000;
typedef _Fn = void Function();

const kTileHeight = 50.0;

const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);
final Iterable<Duration> pauses = [
  // const Duration(milliseconds: 500),
  const Duration(milliseconds: 1000),
];

class HandOperatePage extends StatefulWidget {
  const HandOperatePage({super.key});

  @override
  State<HandOperatePage> createState() => _HandOperatePageState();
}

class _HandOperatePageState extends State<HandOperatePage> {
  String model = "";
  String audio = "";
  String result = "";
  bool is_procces = false;

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String? _mPath = 'flutter_sound_example.wav';
  StreamSubscription? _mRecordingDataSubscription;
  String _recorderTxt = '00:00:00';
  var _loopLength = 7;
  var _maxLength = 59;
  int _processIndex = -1;

  // double _dbLevel = 0.0;

  int value = 0;
  bool positive = true;
  bool loading = false;

  final List<String> items = ['中文', 'English', '其他语言'];

  List<Map> list = [
    // {"title": "Knocking", "subtitle": "English","sort":"People"}
  ];
  final _globalKey = GlobalKey<AnimatedListState>();
  bool cartoonFlag = true;

  String judgePeople(String text) {
    if (text.length == 0) {
      return "empty";
    }
    if (text.contains('[') || text.contains('(')) {
      return "others";
    }
    return "people";
  }

  //发出声音
  void deviceBeep() {
    FlutterBeep.beep();
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      FlutterBeep.beep();
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 600), (timer) {
      FlutterBeep.beep();
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 900), (timer) {
      FlutterBeep.beep();
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 1200), (timer) {
      FlutterBeep.beep();
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 1500), (timer) {
      FlutterBeep.beep();
      timer.cancel();
    });
  }

  Widget _buildItem(index) {
    return ListTile(
      title: Text(
        list[index]["title"],
        style: TextStyle(fontSize: 18),
      ),
      subtitle: Text(
        list[index]["subtitle"],
        // style: TextStyle(fontSize: 18),
      ),
      trailing: list[index]["sort"] == "people"
          ? Icon(
              Icons.people,
              color: Colors.red,
            )
          : Icon(
              Icons.star_outline_rounded,
              color: Colors.blue,
            ),
      // trailing: IconButton(
      //   icon: const Icon(Icons.delete),
      //   onPressed: () {
      //     Get.defaultDialog(
      //         title: "警告",
      //         content: const ListTile(
      //           leading: Icon(
      //             Icons.warning,
      //             color: Colors.orange,
      //           ),
      //           title: const Text("删除后无法恢复，确认删除吗？"),
      //         ),
      //         textConfirm: "确认",
      //         confirmTextColor: Colors.white,
      //         textCancel: "取消",
      //         onCancel: () {},
      //         onConfirm: () {
      //           _deleteItem(index);
      //           Get.back();
      //           CoolAlert.show(
      //             confirmBtnText: "确定",
      //             backgroundColor: Colors.white,
      //             context: context,
      //             type: CoolAlertType.info,
      //             text: "删除成功",
      //           );
      //         }
      //         );
      //   },
      // ),
    );
  }

  //执行删除
  _deleteItem(index) {
    if (cartoonFlag == true) {
      cartoonFlag = false;
      _globalKey.currentState!.removeItem(index, (context, animation) {
        var removeItem = _buildItem(index);
        list.removeAt(index);
        return FadeTransition(
          opacity: animation,
          child: removeItem,
        );
      });
      //解决快速删除动画报错的Bug
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        cartoonFlag = true;
        timer.cancel();
      });
    }
  }

  String selectLanguage(String item) {
    if (item == '中文') {
      return 'zh';
    }
    if (item == 'English') {
      return 'en';
    }
    return 'id';
  }

  String? selectedValue = '中文';

  @override
  void initState() {
    super.initState();
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    beginChooseModel();
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    _openRecorder();
    Intl.defaultLocale = 'zh_CN';
  }

  void beginChooseModel() async {
    FilePickerResult? resul = await FilePicker.platform.pickFiles();
    if (resul != null) {
      File file = File(resul.files.single.path!);
      if (file.existsSync()) {
        setState(() {
          model = file.path;
        });
      }
    }
  }

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  Future<void> _openRecorder() async {
    //初始化录音，initState触发
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    await _mRecorder!.setSubscriptionDuration(Duration(milliseconds: 50));
    setState(() {
      _mRecorderIsInited = true;
    });
  }

  /// 取消录音监听
  void _cancelRecorderSubscriptions() {
    if (_mRecordingDataSubscription != null) {
      _mRecordingDataSubscription?.cancel();
      _mRecordingDataSubscription = null;
    }
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    stopRecorder();
    _mRecorder!.closeRecorder();
    _mRecorder = null;

    _cancelRecorderSubscriptions();
    super.dispose();
  }

  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/temp.wav';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  // ----------------------  Here is the code to record to a Stream ------------

  void record() async {
    assert(_mRecorderIsInited && _mPlayer!.isStopped);
    var sink = await createFile();
    // var recordingDataController = StreamController<Food>();
    // _mRecordingDataSubscription =
    //     recordingDataController.stream.listen((buffer) {
    //   if (buffer is FoodData) {
    //     sink.add(buffer.data!);
    //   }
    // });
    _mRecorder!
        .startRecorder(
      // toStream: recordingDataController.sink,
      sampleRate: tSampleRate,
      toFile: _mPath,
      codec: Codec.pcm16WAV,
    )
        .then((value) {
      // Get.changeTheme(
      //     ThemeData(scaffoldBackgroundColor: Color.fromARGB(255, 0, 0, 0)));
      Get.changeTheme(ThemeData.dark());
      setState(() {
        _processIndex = 0;
      });
    });

    /// 监听录音
    _mRecordingDataSubscription = _mRecorder!.onProgress!.listen((e) {
      if (e != null && e.duration != null) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(
            e.duration.inMilliseconds,
            isUtc: true);

        var txt = DateFormat('mm:ss:SS', 'zh_CN').format(date);
        if (date.second >= _loopLength && !positive) {
          Get.changeTheme(ThemeData.light());
          stopRecorder().then((value) => setState(() {}));
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            readyTotransfer();
            timer.cancel();
          });
        }
        setState(() {
          // print('${date.second}');
          _recorderTxt = txt.substring(0, 8);

          // _dbLevel = e.decibels;
        });
      }
    });
  }
  // ----------------------------------------

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    _mplaybackReady = true;
    // _dbLevel = 0.0;
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped || is_procces) {
      return null;
    }
    return _mRecorder!.isStopped
        ? record
        : () {
            //停止录音
            // Get.changeTheme(ThemeData(scaffoldBackgroundColor: Colors.white));
            Get.changeTheme(ThemeData.light());
            stopRecorder().then((value) => setState(() {}));
            Timer.periodic(Duration(milliseconds: 500), (timer) {
              readyTotransfer();
              timer.cancel();
            });
          };
  }

  Future<void> readyTotransfer() async {
    if (is_procces) {
      return await CoolAlert.show(
        confirmBtnText: "确定",
        backgroundColor: Colors.white,
        context: context,
        type: CoolAlertType.info,
        text: "正在处理中，请稍等",
      );
    }
    // if (audio.isEmpty) {
    if (!_mplaybackReady) {
      await CoolAlert.show(
        confirmBtnText: "确定",
        backgroundColor: Colors.white,
        context: context,
        type: CoolAlertType.warning,
        text: "未录取任何声音",
      );
      if (kDebugMode) {
        print("audio is empty");
      }
      return;
    }
    if (model.isEmpty) {
      await CoolAlert.show(
          confirmBtnText: "确定",
          backgroundColor: Colors.white,
          context: context,
          type: CoolAlertType.warning,
          text: "未选择模型");
      if (kDebugMode) {
        print("model is empty");
      }
      return;
    }
    if (_mRecorder!.isRecording) {
      return await CoolAlert.show(
        confirmBtnText: "确定",
        backgroundColor: Colors.white,
        context: context,
        type: CoolAlertType.info,
        text: "正在录音中，请稍后",
      );
    }
    if (positive) {
      await Get.defaultDialog(
          // contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          title: "下一步",
          content: const ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.green,
            ),
            title: const Text("Whisper准备就绪！"),
          ),
          textConfirm: "开始",
          confirmTextColor: Colors.white,
          textCancel: "取消",
          onCancel: () {
            Get.back();
          },
          onConfirm: () {
            Get.back();
            Future(() async {
              print("开始翻译");
              EasyLoading.show(status: '解析中');
              Whisper whisper = Whisper(
                whisperLib: "libwhisper.so",
              );
              var res = await whisper.request(
                whisperRequest: WhisperRequest.fromWavFile(
                  language: selectLanguage(selectedValue!),
                  // is_translate:true,
                  audio: File(_mPath!),
                  // audio: File(audio),
                  model: File(model),
                ),
              );
              setState(() {
                result = res.toString();
                result = res["text"];
                print('翻译内容：$result');
                String tempSort = judgePeople(result);
                list.add({
                  "title": convert(result, tempSort),
                  "subtitle": selectedValue,
                  "sort": tempSort
                });
                is_procces = false;
                _processIndex = 2; //分析完成
                if (tempSort == "people") {
                  deviceBeep();
                  alertBack();
                }
                Vibrate.vibrateWithPauses(pauses);
                EasyLoading.dismiss();
                CoolAlert.show(
                  confirmBtnText: "确定",
                  context: context,
                  type: CoolAlertType.success,
                  backgroundColor: Colors.white,
                  text: "分析成功：\"$result\"",
                );
              });
            });
            setState(() {
              is_procces = true;
              _processIndex = 1; //分析中
            });
          });
    } else if (!positive) {
      Future(() async {
        print("开始翻译");
        EasyLoading.show(status: '解析中');
        Whisper whisper = Whisper(
          whisperLib: "libwhisper.so",
        );
        var res = await whisper.request(
          whisperRequest: WhisperRequest.fromWavFile(
            language: selectLanguage(selectedValue!),
            // is_translate:true,
            audio: File(_mPath!),
            // audio: File(audio),
            model: File(model),
          ),
        );
        setState(() {
          result = res.toString();
          result = res["text"];
          print('翻译内容：$result');
          String tempSort = judgePeople(result);
          list.add({
            "title": convert(result, tempSort),
            "subtitle": selectedValue,
            "sort": tempSort
          });
          is_procces = false;
          _processIndex = 2; //分析完成
          if (tempSort == "people") {
            deviceBeep();
            alertBack();
          }
          Vibrate.vibrateWithPauses(pauses);
          EasyLoading.dismiss();
          Vibrate.vibrateWithPauses(pauses);
          EasyLoading.showSuccess('可开始下一次分析', duration: Duration(seconds: 1));
          // Timer.periodic(Duration(milliseconds: 500), (timer) {
          //   getRecorderFn();
          //   // print("1111");
          //   timer.cancel();
          // });
        });
      });
      setState(() {
        is_procces = true;
        _processIndex = 1; //分析中
      });
    }
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    await _mPlayer!.startPlayer(
        fromURI: _mPath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() {});
        }); // The readability of Dart is very special :-(
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer!.stopPlayer();
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  // ----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("听音"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.lightbulb),
        onPressed: () {
          readyTotransfer();
        },
      ),
      drawer: Drawer(
        width: 240,
        child: ListView(children: [
          SizedBox(
            height: 50,
          ),
          Center(
              child: const Text("历史记录",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: ScreenUtil().screenHeight - 75,
            child: AnimatedList(
              key: _globalKey,
              initialItemCount: list.length,
              itemBuilder: (context, index, animation) {
                return FadeTransition(
                    opacity: animation, child: _buildItem(index));
              },
            ),
          )
        ]),
      ),
      body: ListView(children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: 300,
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedToggleSwitch<bool>.dual(
                current: positive,
                first: true,
                second: false,
                dif: 50.0,
                borderColor: Colors.transparent,
                borderWidth: 5.0,
                height: 55,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1.5),
                  ),
                ],
                onChanged: (b) {
                  if (_mRecorder!.isRecording) {
                    //录音中禁止切换模式
                    return null;
                  }
                  setState(() => positive = b);
                  return Future.delayed(Duration(milliseconds: 500));
                },
                colorBuilder: (b) => b
                    ? Color.fromARGB(255, 255, 174, 0)
                    : Color.fromARGB(255, 0, 102, 255),
                iconBuilder: (value) => value
                    ? Icon(
                        Icons.handshake_rounded,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.loop_rounded,
                        color: Colors.white,
                      ),
                textBuilder: (value) => value
                    ? Center(
                        child: Text(
                        '手动录音',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ))
                    : Center(
                        child: Text(
                        '快速听音',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),
              ),
              Visibility(
                visible: !is_procces,
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Row(
                    children: const [
                      Icon(
                        Icons.language,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          '语言',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value as String;
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    width: 120,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                      color: Colors.black,
                    ),
                    elevation: 2,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                    ),
                    iconSize: 20,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.grey,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: 150,
                    padding: null,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.lightBlue,
                    ),
                    elevation: 8,
                    offset: const Offset(-15, -5),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all<double>(6),
                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 14),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                key: UniqueKey(),
                margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
                child: Text(
                  _recorderTxt,
                  style: TextStyle(
                    fontSize: 35.0,
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: Text("Result: ${result}"),
              // ),
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: getRecorderFn(),
                      child: Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 200,
                        // key: UniqueKey(),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          // border:
                          // Border.all(color: Colors.black, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5), // 阴影的颜色
                              offset: Offset(0, 5), // 阴影与容器的距离
                              blurRadius: 10.0, // 高斯的标准偏差与盒子的形状卷积。
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: Icon(
                          // Icons.play_arrow_rounded,
                          _mRecorder!.isRecording
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: _mRecorder!.isRecording
                              ? Colors.green
                              : Colors.blue,
                          size: 80,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 250,
          child: Timeline.tileBuilder(
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme: ConnectorThemeData(
                space: 30.0,
                thickness: 5.0,
              ),
            ),
            builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemExtentBuilder: (_, __) =>
                  MediaQuery.of(context).size.width / _processes.length,
              oppositeContentsBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Image.asset(
                    'assets/images/process_timeline/status${index + 1}.png',
                    width: 50.0,
                    color: getColor(index),
                  ),
                );
              },
              contentsBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _processes[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getColor(index),
                    ),
                  ),
                );
              },
              indicatorBuilder: (_, index) {
                var color;
                var child;
                if (index == _processIndex && index != 2) {
                  color = inProgressColor;
                  child = Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  );
                } else if (index == _processIndex && index == 2) {
                  color = inProgressColor;
                  child = Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.0,
                  );
                } else if (index < _processIndex) {
                  color = completeColor;
                  child = Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.0,
                  );
                } else {
                  color = todoColor;
                }

                if (index <= _processIndex) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(30.0, 30.0),
                        painter: _BezierPainter(
                          color: color,
                          drawStart: index > 0,
                          drawEnd: index < _processIndex,
                        ),
                      ),
                      DotIndicator(
                        size: 30.0,
                        color: color,
                        child: child,
                      ),
                    ],
                  );
                } else {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(15.0, 15.0),
                        painter: _BezierPainter(
                          color: color,
                          drawEnd: index < _processes.length - 1,
                        ),
                      ),
                      OutlinedDotIndicator(
                        borderWidth: 4.0,
                        color: color,
                      ),
                    ],
                  );
                }
              },
              connectorBuilder: (_, index, type) {
                if (index > 0) {
                  if (index == _processIndex) {
                    final prevColor = getColor(index - 1);
                    final color = getColor(index);
                    List<Color> gradientColors;
                    if (type == ConnectorType.start) {
                      gradientColors = [
                        Color.lerp(prevColor, color, 0.5)!,
                        color
                      ];
                    } else {
                      gradientColors = [
                        prevColor,
                        Color.lerp(prevColor, color, 0.5)!
                      ];
                    }
                    return DecoratedLineConnector(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                    );
                  } else {
                    return SolidLineConnector(
                      color: getColor(index),
                    );
                  }
                } else {
                  return null;
                }
              },
              itemCount: _processes.length,
            ),
          ),
        ),
        // _timeShow(),
        // ElevatedButton(
        //     onPressed: () {

        //     },
        //     child: Text("111"))
      ]),
    );
  }

  String convert(String result, String sort) {
    if (sort == "empty") {
      return "无声音";
    }
    if (sort == "people") {
      return result;
    }
    return "杂音(可能含敲击声)";
  }

  void alertBack() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      Get.changeTheme(ThemeData(scaffoldBackgroundColor: Colors.red));
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      Get.changeTheme(ThemeData(scaffoldBackgroundColor: Colors.white));
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 1500), (timer) {
      Get.changeTheme(ThemeData(scaffoldBackgroundColor: Colors.red));
      timer.cancel();
    });
    Timer.periodic(Duration(milliseconds: 2000), (timer) {
      Get.changeTheme(ThemeData(scaffoldBackgroundColor: Colors.white));
      timer.cancel();
    });
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}

final _processes = ['正在听音', '分析中', '分析完毕'];
