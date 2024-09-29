part of '../screens.dart';

class FullVideoScreen extends StatefulWidget {
  const FullVideoScreen({
    super.key,
    required this.link,
    required this.title,
    this.isLive = false,
  });
  final String link;
  final String title;
  final bool isLive;

  @override
  State<FullVideoScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<FullVideoScreen> {
  late VlcPlayerController _videoPlayerController;
  bool isPlayed = true;
  bool progress = true;
  bool showControllersVideo = true;
  String position = '';
  String duration = '';
  double sliderValue = 0.0;
  bool validPosition = false;
  double _currentVolume = 0.0;
  double _currentBright = 0.0;
  late Timer timer;

  final ScreenBrightnessUtil _screenBrightnessUtil = ScreenBrightnessUtil();

  _settingPage() async {
    try {
      double brightness = await _screenBrightnessUtil.getBrightness();
      if (brightness == -1) {
        debugPrint("Oops... something wrong!");
      } else {
        _currentBright = brightness;
      }

      ///default volume is half
      VolumeController().listener((volume) {
        setState(() => _currentVolume = volume);
      });
      VolumeController().getVolume().then((volume) => _currentVolume = volume);

      setState(() {});
    } catch (e) {
      debugPrint("Error: setting: $e");
    }
  }

  @override
  void initState() {
    Wakelock.enable();
    _videoPlayerController = VlcPlayerController.network(
      widget.link,
      hwAcc: HwAcc.full,
      autoPlay: true,
      autoInitialize: true,
      options: VlcPlayerOptions(),
    );

    super.initState();
    _videoPlayerController.addListener(listener);
    _settingPage();

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (showControllersVideo) {
        setState(() {
          showControllersVideo = false;
        });
      }
    });
  }

  void listener() async {
    if (!mounted) return;

    if (progress) {
      if (_videoPlayerController.value.isPlaying) {
        setState(() {
          progress = false;
        });
      }
    }

    if (_videoPlayerController.value.isInitialized) {
      var oPosition = _videoPlayerController.value.position;
      var oDuration = _videoPlayerController.value.duration;

      if (oDuration.inHours == 0) {
        var strPosition = oPosition.toString().split('.')[0];
        var strDuration = oDuration.toString().split('.')[0];
        position = "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
        duration = "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
      } else {
        position = oPosition.toString().split('.')[0];
        duration = oDuration.toString().split('.')[0];
      }
      validPosition = oDuration.compareTo(oPosition) >= 0;
      sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      setState(() {});
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    _videoPlayerController.setTime(sliderValue.toInt() * 1000);
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
    timer.cancel();
    VolumeController().removeListener();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("SIZE: ${MediaQuery.of(context).size.width}");
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: getSize(context).width,
            height: getSize(context).height,
            color: Colors.black,
            child: VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: 16 / 9,
              virtualDisplay: true,
              placeholder: const SizedBox(),
            ),
          ),

          if (progress)
            const Center(
                child: CircularProgressIndicator(
              color: kColorPrimary,
            )),

          ///Controllers
          GestureDetector(
            onTap: () {
              setState(() {
                showControllersVideo = !showControllersVideo;
              });
            },
            child: Container(
              width: getSize(context).width,
              height: getSize(context).height,
              color: Colors.transparent,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: !showControllersVideo
                    ? const SizedBox()
                    : SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ///Back & Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  focusColor: kColorFocus,
                                  onPressed: () async {
                                    await Future.delayed(
                                            const Duration(milliseconds: 1000))
                                        .then((value) {
                                      Get.back(
                                          result: progress
                                              ? null
                                              : [
                                                  sliderValue,
                                                  _videoPlayerController
                                                      .value.duration.inSeconds
                                                      .toDouble()
                                                ]);
                                    });
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    size: 19.sp,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    style: Get.textTheme.labelLarge!.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ///Slider & Play/Pause
                            if (!progress && !widget.isLive)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        activeColor: kColorPrimary,
                                        inactiveColor: Colors.white,
                                        value: sliderValue,
                                        min: 0.0,
                                        max: (!validPosition)
                                            ? 1.0
                                            : _videoPlayerController
                                                .value.duration.inSeconds
                                                .toDouble(),
                                        onChanged: validPosition
                                            ? _onSliderPositionChanged
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      "$position / $duration",
                                      style: Get.textTheme.titleSmall!.copyWith(
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          if (!progress && showControllersVideo)

            ///Controllers Light, Lock...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!isTv(context))
                  FillingSlider(
                    direction: FillingSliderDirection.vertical,
                    initialValue: _currentVolume,
                    onFinish: (value) async {
                      VolumeController().setVolume(value);
                      setState(() {
                        _currentVolume = value;
                      });
                    },
                    fillColor: Colors.white54,
                    height: 40.h,
                    width: 30,
                    child: Icon(
                      _currentVolume < .1
                          ? FontAwesomeIcons.volumeXmark
                          : _currentVolume < .7
                              ? FontAwesomeIcons.volumeLow
                              : FontAwesomeIcons.volumeHigh,
                      color: Colors.black,
                      size: 13,
                    ),
                  ),
                Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (isPlayed) {
                          _videoPlayerController.pause();
                          isPlayed = false;
                        } else {
                          _videoPlayerController.play();
                          isPlayed = true;
                        }
                      });
                    },
                    icon: Icon(
                      isPlayed ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                      size: 24.sp,
                    ),
                  ),
                ),
                if (!isTv(context))
                  FillingSlider(
                    initialValue: _currentBright,
                    direction: FillingSliderDirection.vertical,
                    fillColor: Colors.white54,
                    height: 40.h,
                    width: 30,
                    onFinish: (value) async {
                      bool success =
                          await _screenBrightnessUtil.setBrightness(value);

                      setState(() {
                        _currentBright = value;
                      });
                    },
                    child: Icon(
                      _currentBright < .1
                          ? FontAwesomeIcons.moon
                          : _currentVolume < .7
                              ? FontAwesomeIcons.sun
                              : FontAwesomeIcons.solidSun,
                      color: Colors.black,
                      size: 13,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
