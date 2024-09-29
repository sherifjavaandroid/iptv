part of '../screens.dart';

class LiveChannelsScreen extends StatefulWidget {
  const LiveChannelsScreen({super.key, required this.catyId});
  final String catyId;

  @override
  State<LiveChannelsScreen> createState() => _ListChannelsScreen();
}

class _ListChannelsScreen extends State<LiveChannelsScreen> {
  VlcPlayerController? _videoPlayerController;

  int? selectedVideo;
  String? selectedStreamId;
  ChannelLive? channelLive;
  double lastPosition = 0.0;
  String keySearch = "";
  final FocusNode _remoteFocus = FocusNode();

  _initialVideo(String streamId) async {
    UserModel? user = await LocaleApi.getUser();

    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _videoPlayerController!.pause();
      _videoPlayerController!.stop();
      _videoPlayerController = null;
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      _videoPlayerController = null;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    var videoUrl =
        "${user!.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/$streamId";

    debugPrint("Load Video: $videoUrl");
    _videoPlayerController = VlcPlayerController.network(
      videoUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
          VlcAdvancedOptions.liveCaching(2000),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          catyId: widget.catyId,
          typeCategory: TypeCategory.live,
        ));
    super.initState();
  }

  @override
  void dispose() async {
    _remoteFocus.dispose();
    super.dispose();
    if (_videoPlayerController != null) {
      await _videoPlayerController!.stopRendererScanning();
      await _videoPlayerController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, stateVideo) {
        return WillPopScope(
          onWillPop: () async {
            debugPrint("Back pressed");
            if (stateVideo.isFull) {
              context.read<VideoCubit>().changeUrlVideo(false);

              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, stateAuth) {
              if (stateAuth is AuthSuccess) {
                final userAuth = stateAuth.user;

                return Scaffold(
                  body: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Ink(
                        width: 100.w,
                        height: 100.h,
                        decoration: kDecorBackground,
                        // padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 10),
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                if (stateVideo.isFull) {
                                  return const SizedBox();
                                }
                                return WillPopScope(
                                  onWillPop: () async {
                                    debugPrint("Back pressed");
                                    if (stateVideo.isFull) {
                                      context
                                          .read<VideoCubit>()
                                          .changeUrlVideo(false);
                                      return Future.value(false);
                                    } else {
                                      return Future.value(true);
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 3.h),
                                      BlocBuilder<FavoritesCubit,
                                          FavoritesState>(
                                        builder: (context, state) {
                                          final isLiked = channelLive == null
                                              ? false
                                              : state.lives
                                                  .where((live) =>
                                                      live.streamId ==
                                                      channelLive!.streamId)
                                                  .isNotEmpty;
                                          return AppBarLive(
                                            isLiked: isLiked,
                                            onLike: channelLive == null
                                                ? null
                                                : () {
                                                    context
                                                        .read<FavoritesCubit>()
                                                        .addLive(channelLive,
                                                            isAdd: !isLiked);
                                                  },
                                            onSearch: (String value) {
                                              setState(() {
                                                keySearch = value;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      bool setFull = stateVideo.isFull;
                                      if (setFull) {
                                        return const SizedBox();
                                      }
                                      return Expanded(
                                        child: BlocBuilder<ChannelsBloc,
                                            ChannelsState>(
                                          builder: (context, state) {
                                            if (state is ChannelsLoading) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (state
                                                is ChannelsLiveSuccess) {
                                              final categories = state.channels;

                                              List<ChannelLive> searchList =
                                                  categories
                                                      .where((element) =>
                                                          element.name!
                                                              .toLowerCase()
                                                              .contains(
                                                                  keySearch))
                                                      .toList();

                                              return GridView.builder(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 80,
                                                ),
                                                itemCount: keySearch.isEmpty
                                                    ? categories.length
                                                    : searchList.length,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      selectedVideo == null
                                                          ? 2
                                                          : 1,
                                                  mainAxisSpacing: 10,
                                                  crossAxisSpacing:
                                                      selectedVideo == null
                                                          ? 10
                                                          : 0,
                                                  childAspectRatio: 7,
                                                ),
                                                itemBuilder: (_, i) {
                                                  final model =
                                                      keySearch.isEmpty
                                                          ? categories[i]
                                                          : searchList[i];

                                                  final link =
                                                      "${userAuth.serverInfo!.serverUrl}/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${model.streamId}";

                                                  return CardLiveItem(
                                                    title: model.name ?? "",
                                                    image: model.streamIcon,
                                                    link: link,
                                                    isSelected: selectedVideo ==
                                                            null
                                                        ? false
                                                        : selectedVideo == i,
                                                    onTap: () async {
                                                      try {
                                                        if (selectedVideo ==
                                                                i &&
                                                            _videoPlayerController !=
                                                                null) {
                                                          // OPEN FULL SCREEN
                                                          debugPrint(
                                                              "///////////// OPEN FULL STREAM /////////////");
                                                          context
                                                              .read<
                                                                  VideoCubit>()
                                                              .changeUrlVideo(
                                                                  true);
                                                        } else {
                                                          ///Play new Stream
                                                          debugPrint(
                                                              "Play new Stream");

                                                          _initialVideo(model
                                                              .streamId
                                                              .toString());

                                                          if (mounted) {
                                                            setState(() {
                                                              selectedVideo = i;
                                                              channelLive =
                                                                  model;
                                                              selectedStreamId =
                                                                  model
                                                                      .streamId;
                                                            });
                                                          }
                                                        }
                                                      } catch (e) {
                                                        debugPrint("error: $e");
                                                        //  context.read<VideoCubit>().changeUrlVideo(false);

                                                        // selectedVideo = null;
                                                        _videoPlayerController =
                                                            null;
                                                        setState(() {
                                                          channelLive = model;
                                                          selectedStreamId =
                                                              model.streamId;
                                                        });
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            }

                                            return const Center(
                                              child: Text(
                                                  "Failed to load data..."),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  if (selectedVideo != null)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: StreamPlayerPage(
                                              controller:
                                                  _videoPlayerController,
                                            ),
                                          ),
                                          Builder(
                                            builder: (context) {
                                              if (stateVideo.isFull) {
                                                return const SizedBox();
                                              }

                                              ///Get EPG
                                              return CardEpgStream(
                                                  streamId: selectedStreamId);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedVideo == null) AdmobWidget.getBanner(),
                    ],
                  ),
                );
              }

              return const Scaffold();
            },
          ),
        );
      },
    );
  }
}

class CardEpgStream extends StatelessWidget {
  const CardEpgStream({super.key, required this.streamId});
  final String? streamId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: streamId == null
          ? const SizedBox()
          : FutureBuilder<List<EpgModel>>(
              future: IpTvApi.getEPGbyStreamId(streamId ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final list = snapshot.data;

                return Container(
                  decoration: const BoxDecoration(
                      color: kColorCardLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                      )),
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView.separated(
                    itemCount: list!.length,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    itemBuilder: (_, i) {
                      final model = list[i];
                      String description =
                          utf8.decode(base64.decode(model.description ?? ""));

                      String title =
                          utf8.decode(base64.decode(model.title ?? ""));
                      return CardEpg(
                        title:
                            "${getTimeFromDate(model.start ?? "")} - ${getTimeFromDate(model.end ?? "")} - $title",
                        description: description,
                        isSameTime: checkEpgTimeIsNow(
                            model.start ?? "", model.end ?? ""),
                      );
                    },
                    separatorBuilder: (_, i) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                  ),
                );
              }),
    );
  }
}

class CardEpg extends StatelessWidget {
  const CardEpg(
      {super.key,
      required this.title,
      required this.description,
      required this.isSameTime});
  final String title;
  final String description;
  final bool isSameTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            color: isSameTime ? kColorPrimaryDark : Colors.white,
          ),
        ),
        Text(
          description,
          style: Get.textTheme.bodyMedium!.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
