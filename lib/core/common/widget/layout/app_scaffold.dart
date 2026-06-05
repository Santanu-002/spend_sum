import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_sum/core/common/widget/button/app_back_button.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

/// A custom, premium adaptive scaffold widget that applies a consistent top-to-bottom background gradient,
/// handles tap gestures on the body to dismiss the keyboard/unfocus text fields,
/// configures a modular AppBar with title/actions/back navigation, and supports optional footer containers.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final bool? centerTitle;
  final double? titleSpacing;
  final VoidCallback? onBackPressed;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final bool useScrollView;
  final Widget? footer;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final bool showAppBar;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool useRefreshIndicator;
  final RefreshCallback? onRefresh;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.centerTitle,
    this.titleSpacing,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.useScrollView = false,
    this.footer,
    this.drawer,
    this.endDrawer,
    this.leading,
    this.padding,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.showAppBar = true,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.useRefreshIndicator = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    Widget bodyContent = useScrollView || useRefreshIndicator
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // allows refresh drag gesture even when content fits
            padding: padding ?? EdgeInsets.zero,
            child: child,
          )
        : Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          );

    if (useRefreshIndicator && onRefresh != null) {
      bodyContent = RefreshIndicator(
        onRefresh: onRefresh!,
        color: themeExt.primary,
        backgroundColor: themeExt.cardColor,
        child: bodyContent,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeExt.backgroundGradientStart,
            themeExt.backgroundGradientEnd,
          ],
          stops: const [0.0, 0.45],
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: drawer,
          endDrawer: endDrawer,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomNavigationBar: bottomNavigationBar,
          extendBody: extendBody,
          appBar: showAppBar
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  titleSpacing: titleSpacing,
                  centerTitle: centerTitle ?? true,
                  title:
                      titleWidget ??
                      (title != null
                          ? Text(
                              title!,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: themeExt.onSurface,
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          : null),
                  systemOverlayStyle: theme.brightness == Brightness.light
                      ? SystemUiOverlayStyle.dark
                      : SystemUiOverlayStyle.light,
                  actions: actions,
                  automaticallyImplyLeading: false,
                  leadingWidth: leading != null
                      ? null
                      : ((onBackPressed != null ||
                              (automaticallyImplyLeading &&
                                  (ModalRoute.of(context)?.canPop ?? false)))
                          ? 40 + AppDimensions.marginPage
                          : null),
                  leading:
                      leading ??
                      ((onBackPressed != null ||
                              (automaticallyImplyLeading &&
                                  (ModalRoute.of(context)?.canPop ?? false)))
                          ? Padding(
                              padding: const EdgeInsets.only(left: AppDimensions.marginPage),
                              child: AppBackButton(
                                onPressed: onBackPressed,
                                color: themeExt.onSurface,
                              ),
                            )
                          : null),
                )
              : null,
          body: SafeArea(
            bottom: !extendBody,
            child: Column(
              children: [
                Expanded(
                  child: bodyContent,
                ),
                if (footer != null)
                  Padding(
                    padding:
                        padding ??
                        const EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginPage,
                        ),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
