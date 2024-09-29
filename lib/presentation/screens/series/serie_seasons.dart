part of '../screens.dart';

class SerieSeasons extends StatefulWidget {
  const SerieSeasons({super.key, required this.serieDetails});
  final SerieDetails serieDetails;

  @override
  State<SerieSeasons> createState() => _SerieSeasonsState();
}

class _SerieSeasonsState extends State<SerieSeasons> {
  late SerieDetails serieDetails;
  int selectedSeason = 0;
  int selectedEpisode = 0;

  @override
  void initState() {
    serieDetails = widget.serieDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> seasons = [];
    if (serieDetails.episodes != null && serieDetails.episodes!.isNotEmpty) {
      serieDetails.episodes!.forEach((k, v) {
        seasons.add(k);
      });
    }

    return Scaffold(
      body: Ink(
        decoration: kDecorBackground,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userAuth = state.user;
              return Stack(
                children: [
                  CardMovieImagesBackground(
                    listImages: serieDetails.info!.backdropPath ?? [],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.h, left: 10, right: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100.w,
                          width: 22.w,
                          child: Center(
                            child: ListView.builder(
                              itemCount: seasons.length,
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemBuilder: (_, i) {
                                return CardSeasonItem(
                                  isSelected: i == selectedSeason,
                                  number: seasons[i],
                                  onTap: () {
                                    setState(() {
                                      selectedSeason = i;
                                    });
                                  },
                                  onFocused: (val) {
                                    setState(() {
                                      selectedSeason = i;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: serieDetails
                                .episodes!["${selectedSeason + 1}"]!.length,
                            itemBuilder: (_, i) {
                              final model = serieDetails
                                  .episodes!["${selectedSeason + 1}"]![i];

                              return CardEpisodeItem(
                                isSelected: selectedEpisode == i,
                                index: i + 1,
                                episode: model,
                                onTap: () {
                                  setState(() {
                                    selectedEpisode = i;
                                  });
                                  final link =
                                      "${userAuth.serverInfo!.serverUrl}/series/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${model!.id}.${model.containerExtension}";

                                  debugPrint("Link: $link");
                                  Get.to(() => FullVideoScreen(
                                            link: link,
                                            title: model.title ?? "",
                                          ))!
                                      .then((slider) {
                                    debugPrint("DATA: $slider");
                                    if (slider != null) {
                                      var modell = WatchingModel(
                                        sliderValue: slider[0],
                                        durationStrm: slider[1],
                                        stream: link,
                                        title: model.title ?? "",
                                        image: model.info!.movieImage ??
                                            widget.serieDetails.info!.cover ??
                                            "",
                                        streamId: model.id.toString(),
                                      );
                                      context
                                          .read<WatchingCubit>()
                                          .addSerie(modell);
                                    }
                                  });
                                },
                                onFocused: (val) {
                                  setState(() {
                                    selectedEpisode = i;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppBarSeries(
                    top: 3.h,
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
