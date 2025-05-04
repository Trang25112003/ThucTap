import 'package:flutter/material.dart';
import 'package:job_supabase/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  String _selectedLanguage = 'en';
  final List<String> _supportedLanguages = ['en', 'vi'];
  bool isLoading = false; // ✅ Thêm trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_locale');
    if (savedLanguage != null && _supportedLanguages.contains(savedLanguage)) {
      setState(() {
        _selectedLanguage = savedLanguage;
      });
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

Future<void> _saveLanguage() async {
  setState(() {
    isLoading = true;
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_locale', _selectedLanguage);
  final newLocale = Locale(_selectedLanguage);

  final myAppState = MyApp.myAppStateKey.currentState;
  if (myAppState != null) {
    myAppState.setLocale(newLocale);
  }

  await Future.delayed(const Duration(milliseconds: 800)); 

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  Navigator.pop(context); 
}


  Widget _buildLanguageItem(String languageCode, String languageName, String flagAsset) {
    final isSelected = _selectedLanguage == languageCode;
    return InkWell(
      onTap: () => _changeLanguage(languageCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Image.asset(flagAsset, width: 24, height: 24, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(languageName, style: const TextStyle(fontWeight: FontWeight.w500))),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.purple : Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('choose language ', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _buildLanguageItem('en', 'English', 'assets/flags/gb.png'),
            const SizedBox(height: 12),
            _buildLanguageItem('vi', 'Vietnamese', 'assets/flags/vn.png'),
            const Spacer(),
            isLoading
                ? const Center(child: CircularProgressIndicator()) // ✅ Loading xoay tròn
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveLanguage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Select', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
