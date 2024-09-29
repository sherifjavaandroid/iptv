part of '../screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userInfo = state.user;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppBarSettings(),
                  SizedBox(height: 5.h),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: kColorCardLight,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dateNowWelcome(),
                                        style: Get.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 5),
                                      if (userInfo.userInfo!.expDate != null)
                                        Text(
                                          "Expiration: ${expirationDate(userInfo.userInfo!.expDate)}",
                                          style: Get.textTheme.titleSmall!
                                              .copyWith(
                                            color: kColorHint,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: kColorCardLight,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "name: ${userInfo.userInfo!.username}",
                                        style: Get.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "password: ${userInfo.userInfo!.password}",
                                        style: Get.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 5),
                                      if (userInfo.serverInfo != null)
                                        Text(
                                          "Url: ${userInfo.serverInfo!.serverUrl}",
                                          style: Get.textTheme.titleSmall,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30.w,
                                child: CardButtonWatchMovie(
                                  isFocused: true,
                                  title: "Refresh all data",
                                  onTap: () {
                                    context
                                        .read<LiveCatyBloc>()
                                        .add(GetLiveCategories());
                                    context
                                        .read<MovieCatyBloc>()
                                        .add(GetMovieCategories());
                                    context
                                        .read<SeriesCatyBloc>()
                                        .add(GetSeriesCategories());
                                    Get.back();
                                  },
                                ),
                              ),
                              SizedBox(height: 5.h),
                              SizedBox(
                                width: 30.w,
                                child: CardButtonWatchMovie(
                                  title: "Add New User",
                                  onTap: () {
                                    context.read<AuthBloc>().add(AuthLogOut());
                                    Get.offAllNamed("/");
                                  },
                                ),
                              ),
                              SizedBox(height: 5.h),
                              SizedBox(
                                width: 30.w,
                                child: CardButtonWatchMovie(
                                  title: "LogOut",
                                  onTap: () {
                                    context.read<AuthBloc>().add(AuthLogOut());
                                    Get.offAllNamed("/");
                                    Get.reload();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CreatedBy:',
                        style: Get.textTheme.titleSmall!.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await launchUrlString(
                            "https://mouadzizi.me",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          ' @Azul Mouad',
                          style: Get.textTheme.titleSmall!.copyWith(
                            fontSize: 12.sp,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
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
