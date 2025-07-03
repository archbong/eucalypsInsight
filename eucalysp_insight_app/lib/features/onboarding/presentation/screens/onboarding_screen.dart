// lib/features/onboarding/presentation/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import your brand colors
import 'package:eucalysp_insight_app/features/onboarding/domain/models/onboarding_content.dart';
import 'package:hive/hive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding content for your app
  final List<OnboardingContent> onboardingPages = const [
    OnboardingContent(
      imagePath: 'assets/images/logo-one.png', // Placeholder, create this asset
      title: 'Welcome to Eucalyps Insight!',
      description: 'Your all-in-one solution for smart business management.',
    ),
    OnboardingContent(
      imagePath: 'assets/images/logo-two.png', // Placeholder, create this asset
      title: 'Effortless Inventory Tracking',
      description:
          'Keep tabs on your products, stock levels, and categories with ease.',
    ),
    OnboardingContent(
      imagePath:
          'assets/images/logo-three.png', // Placeholder, create this asset
      title: 'Streamlined Sales & Insights',
      description:
          'Process transactions quickly and gain insights into your sales data.',
    ),
    OnboardingContent(
      imagePath: 'assets/images/logo-one.png', // Placeholder, create this asset
      title: 'Grow Your Business Smarter',
      description:
          'Make informed decisions with powerful analytics and reporting.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      backgroundColor:
          AppColors.backgroundLight, // Use your light background color
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Onboarding Image (Placeholder)
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            page.imagePath,
                            fit: BoxFit.contain,
                            height:
                                MediaQuery.of(context).size.height *
                                0.4, // Responsive height
                          ),
                        ),
                        const SizedBox(height: 40), // spacing-3xl
                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16), // spacing-md
                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page Indicators and Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 32), // spacing-2xl
                  isLastPage
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Mark onboarding as completed
                                  final settingsBox = await Hive.openBox(
                                    'appSettings',
                                  );
                                  await settingsBox.put(
                                    'hasSeenOnboarding',
                                    true,
                                  );
                                  // Navigate to login (auth required for create-business)
                                  if (mounted) {
                                    GoRouter.of(context).go('/login');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary, // Primary button style
                                  foregroundColor: AppColors.textInverse,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ), // radius-lg from app_theme
                                  ),
                                ),
                                child: Text(
                                  'Create New Acount',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors
                                            .textInverse, // Ensure text is white
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // spacing-md
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigate to Select Business Screen
                                  GoRouter.of(context).go('/login');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.borderPrimary,
                                  ), // Primary border color
                                  foregroundColor:
                                      AppColors.primary, // Primary text color
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors
                                            .primary, // Ensure text is primary color
                                      ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Skip to the last page or directly to decision
                                _pageController.jumpToPage(
                                  onboardingPages.length - 1,
                                );
                              },
                              child: Text(
                                'Skip',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeIn,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary, // Use primary color
                                foregroundColor: AppColors.textInverse,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ), // Full pill shape
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppColors.textInverse),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for page indicator dots
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors
                  .borderLight, // Primary for active, borderLight for inactive
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// You might want to extract `AppRadius` into a separate `app_sizing.dart` or keep it here
// for simplicity given its small size. I'll add a temporary placeholder here.
// For a complete solution, integrate this into your AppTheme or a new AppSizing file.
class AppRadius {
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double _2xl = 16.0;
  static const double full = 9999.0; // Corresponds to CSS radius-full
}
