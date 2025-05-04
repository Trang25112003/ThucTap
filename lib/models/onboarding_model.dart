class OnboardingModel {
  final String imagePath;
  final String title;
  final String description;

  OnboardingModel({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

final onboardings = [
  OnboardingModel(
    imagePath: "assets/images/onboarding_1.png",
    title: "Welcome to Our Job Search Platform!",
    description: "Explore the latest technology and discover job opportunities tailored to your skills.",
  ),
  OnboardingModel(
    imagePath: "assets/images/onboarding_2.png",
    title: "Find Your Dream Job with Ease",
    description: "Our smart search and filtering system connects you with top employers effortlessly.",
  ),
  OnboardingModel(
    imagePath: "assets/images/onboarding_3.png",
    title: "Apply Instantly and Get Hired Faster",
    description: "Upload your resume, track your applications, and secure your ideal job in just a few clicks.",
  ),
];
 