import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/home_content_layout.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/home_header_row.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    final userState = context.watch<UserCubit>().state;
    final userId = userState is UserLoggedIn ? userState.user.uid : '';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginPage,
              vertical: 12,
            ),
            child: const HomeHeaderRow(),
          ),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (userId.isNotEmpty) {
                        await context.read<HomeCubit>().loadHomeOverview(userId);
                      }
                    },
                    color: themeExt.primary,
                    backgroundColor: themeExt.cardColor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.marginPage,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          _HomeErrorWidget(message: state.message),
                        ],
                      ),
                    ),
                  );
                }

                final isLoading = state is HomeInitial || state is HomeLoading;
                final data = state is HomeLoaded ? state.data : null;

                return RefreshIndicator(
                  onRefresh: () async {
                    if (userId.isNotEmpty) {
                      await context.read<HomeCubit>().loadHomeOverview(userId);
                    }
                  },
                  color: themeExt.primary,
                  backgroundColor: themeExt.cardColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginPage,
                    ),
                    child: HomeContentLayout(
                      data: data,
                      isLoading: isLoading,
                      themeExt: themeExt,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _HomeErrorWidget extends StatelessWidget {
  final String message;

  const _HomeErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: themeExt.error, size: 48),
          const SizedBox(height: AppDimensions.stackMd),
          Text(
            'Failed to load dashboard data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeExt.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: themeExt.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          ElevatedButton.icon(
            onPressed: () {
              final userState = context.read<UserCubit>().state;
              if (userState is UserLoggedIn) {
                context.read<HomeCubit>().loadHomeOverview(userState.user.uid);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}


