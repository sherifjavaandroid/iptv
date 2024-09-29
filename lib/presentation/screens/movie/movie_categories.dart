part of '../screens.dart';

class MovieCategoriesScreen extends StatefulWidget {
  const MovieCategoriesScreen({super.key});

  @override
  State<MovieCategoriesScreen> createState() => _MovieCategoriesScreenState();
}

class _MovieCategoriesScreenState extends State<MovieCategoriesScreen> {
  final ScrollController _hideButtonController = ScrollController();
  bool _hideButton = true;
  String keySearch = "";

  late InterstitialAd _interstitialAd;
  _loadIntel() async {
    if (!showAds) {
      return false;
    }
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint("Ads is Loaded");
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    _loadIntel();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_hideButton == true) {
          setState(() {
            _hideButton = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_hideButton == false) {
            setState(() {
              _hideButton = true;
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !_hideButton,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _hideButtonController.animateTo(0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease);
              _hideButton = true;
            });
          },
          backgroundColor: kColorPrimaryDark,
          child: const Icon(
            FontAwesomeIcons.chevronUp,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Ink(
            width: 100.w,
            height: 100.h,
            decoration: kDecorBackground,
            child: NestedScrollView(
              controller: _hideButtonController,
              headerSliverBuilder: (_, ch) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: AppBarMovie(
                        onSearch: (String value) {
                          setState(() {
                            keySearch = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                ];
              },
              body: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                builder: (context, state) {
                  if (state is MovieCatyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MovieCatySuccess) {
                    final categories = state.categories;

                    List<CategoryModel> searchList = categories
                        .where((element) => element.categoryName!
                            .toLowerCase()
                            .contains(keySearch))
                        .toList();

                    return GridView.builder(
                      itemCount: keySearch.isEmpty
                          ? categories.length
                          : searchList.length,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 15,
                        bottom: 70,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 5,
                      ),
                      itemBuilder: (_, i) {
                        final model =
                            keySearch.isEmpty ? categories[i] : searchList[i];

                        return CardLiveItem(
                          title: model.categoryName ?? "",
                          onTap: () {
                            // OPEN Channels
                            Get.to(() => MovieChannels(
                                    catyId: model.categoryId ?? ''))!
                                .then((value) async {
                              _interstitialAd.show();
                              _loadIntel();
                            });
                          },
                        );
                      },
                    );
                  }

                  return const Center(
                    child: Text("Failed to load data..."),
                  );
                },
              ),
            ),
          ),
          AdmobWidget.getBanner(),
        ],
      ),
    );
  }
}
