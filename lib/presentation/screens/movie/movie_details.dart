part of '../screens.dart';

class MovieContent extends StatefulWidget {
  const MovieContent(
      {super.key, required this.videoId, required this.channelMovie});
  final String videoId;
  final ChannelMovie channelMovie;

  @override
  State<MovieContent> createState() => _MovieContentState();
}

class _MovieContentState extends State<MovieContent> {
  late Future<MovieDetail?> future;

  @override
  void initState() {
    future = IpTvApi.getMovieDetails(widget.videoId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        decoration: kDecorBackground,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userAuth = state.user;
              return Stack(
                children: [
                  FutureBuilder<MovieDetail?>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text("Could not load data"),
                        );
                      }

                      final movie = snapshot.data;

                      return Stack(
                        children: [
                          CardMovieImagesBackground(
                            listImages: movie!.info!.backdropPath ??
                                [
                                  movie.info!.movieImage ?? "",
                                ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 70, left: 10, right: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CardMovieImageRate(
                                  image: movie.info!.movieImage ?? "",
                                  rate: movie.info!.rating ?? "0",
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.movieData!.name ?? "",
                                          style: Get.textTheme.displaySmall,
                                        ),
                                        const SizedBox(height: 15),
                                        Wrap(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardInfoMovie(
                                              icon:
                                                  FontAwesomeIcons.clapperboard,
                                              hint: 'Director',
                                              title: movie.info!.director ?? "",
                                            ),
                                            CardInfoMovie(
                                              icon:
                                                  FontAwesomeIcons.calendarDay,
                                              hint: 'Release Date',
                                              title: expirationDate(
                                                  movie.info!.releasedate),
                                            ),
                                            CardInfoMovie(
                                              icon: FontAwesomeIcons.clock,
                                              hint: 'Duration',
                                              title: movie.info!.duration ?? "",
                                            ),
                                            CardInfoMovie(
                                              icon: FontAwesomeIcons.users,
                                              hint: 'Cast',
                                              isShowMore: true,
                                              title: movie.info!.cast ?? "",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        CardInfoMovie(
                                          icon: FontAwesomeIcons.film,
                                          hint: 'Genre:',
                                          title: movie.info!.genre ?? "",
                                        ),
                                        const SizedBox(height: 15),
                                        CardInfoMovie(
                                          icon: FontAwesomeIcons
                                              .solidClosedCaptioning,
                                          hint: 'Plot:',
                                          title: movie.info!.plot ?? "",
                                          isShowMore: true,
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            if (movie.info!.youtubeTrailer !=
                                                    null &&
                                                movie.info!.youtubeTrailer!
                                                    .isNotEmpty)
                                              CardButtonWatchMovie(
                                                title: "watch trailer",
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (builder) =>
                                                          DialogTrailerYoutube(
                                                              thumb: movie
                                                                      .info!
                                                                      .backdropPath!
                                                                      .isNotEmpty
                                                                  ? movie
                                                                      .info!
                                                                      .backdropPath!
                                                                      .first
                                                                  : null,
                                                              trailer: movie
                                                                      .info!
                                                                      .youtubeTrailer ??
                                                                  ""));
                                                },
                                              ),
                                            SizedBox(width: 3.w),
                                            CardButtonWatchMovie(
                                              title: "watch Now",
                                              isFocused: true,
                                              onTap: () {
                                                final link =
                                                    "${userAuth.serverInfo!.serverUrl}/movie/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${movie.movieData!.streamId}.${movie.movieData!.containerExtension}";

                                                debugPrint("URL: $link");
                                                Get.to(() => FullVideoScreen(
                                                          link: link,
                                                          title: movie
                                                                  .movieData!
                                                                  .name ??
                                                              "",
                                                        ))!
                                                    .then((slider) {
                                                  debugPrint("DATA: $slider");
                                                  if (slider != null) {
                                                    var model = WatchingModel(
                                                      sliderValue: slider[0],
                                                      durationStrm: slider[1],
                                                      stream: link,
                                                      title: widget.channelMovie
                                                              .name ??
                                                          "",
                                                      image: widget.channelMovie
                                                              .streamIcon ??
                                                          "",
                                                      streamId: widget
                                                          .channelMovie.streamId
                                                          .toString(),
                                                    );
                                                    context
                                                        .read<WatchingCubit>()
                                                        .addMovie(model);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final isLiked = state.movies
                          .where((movie) =>
                              movie.streamId == widget.channelMovie.streamId)
                          .isNotEmpty;
                      return AppBarMovie(
                        isLiked: isLiked,
                        top: 15,
                        onFavorite: () {
                          context
                              .read<FavoritesCubit>()
                              .addMovie(widget.channelMovie, isAdd: !isLiked);
                        },
                      );
                    },
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
