import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luna_iot/app/app_theme.dart';
import 'package:luna_iot/controllers/auth_controller.dart';
import 'package:luna_iot/services/auth_storage_service.dart';
import 'package:luna_iot/views/home_screen.dart';
import 'package:luna_iot/widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _authController;

  bool _obscurePassword = true;
  List<Map<String, String>> _savedAccounts = [];

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _loadSavedAccounts();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load all saved accounts for suggestions
  Future<void> _loadSavedAccounts() async {
    try {
      final accounts = await AuthStorageService.getSavedAccounts();
      setState(() {
        _savedAccounts = accounts;
      });
    } catch (e) {
      print('Error loading saved accounts: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (success) {
        // Show save password dialog after successful login
        _showSavePasswordDialog();
        Get.offAll(() => HomeScreen());
      } else {
        debugPrint('Login failed');
      }
    }
  }

  // Show save password dialog
  void _showSavePasswordDialog() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Save password?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.titleColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Would you like to save your login credentials for Luna IoT? This will make it easier to sign in next time.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subTitleColor,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Not Saved',
                    'Password not saved. You can change this later in settings.',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                },
                child: Text(
                  'Not Now',
                  style: TextStyle(color: AppTheme.subTitleColor, fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save credentials for suggestions
                  await _saveCredentials();
                  Navigator.pop(context);
                  Get.snackbar(
                    'Password Saved!',
                    'Your login credentials have been saved securely.',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // Save credentials for suggestions
  Future<void> _saveCredentials() async {
    try {
      await AuthStorageService.saveCredentials(
        _phoneController.text,
        _passwordController.text,
      );
      // Reload suggestions after saving
      await _loadSavedAccounts();
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  // Show phone suggestions for multiple accounts
  void _showPhoneSuggestions() {
    if (_savedAccounts.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Accounts (${_savedAccounts.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.titleColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showManageAccountsDialog(),
                    icon: Icon(Icons.settings, color: AppTheme.primaryColor),
                    tooltip: 'Manage accounts',
                  ),
                ],
              ),
            ),
            ..._savedAccounts.map(
              (account) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    account['phone']!.substring(0, 1),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(account['phone']!),
                subtitle: Text(
                  'Last used: ${_formatTimestamp(account['timestamp']!)}',
                ),
                onTap: () {
                  _phoneController.text = account['phone']!;
                  // Auto-fill password for this account
                  _passwordController.text = account['password']!;
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  // Show manage accounts dialog
  void _showManageAccountsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Saved Accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You have ${_savedAccounts.length} saved account(s)'),
            SizedBox(height: 16),
            ..._savedAccounts.map(
              (account) => ListTile(
                leading: Icon(Icons.person, color: AppTheme.primaryColor),
                title: Text(account['phone']!),
                trailing: IconButton(
                  onPressed: () async {
                    await AuthStorageService.removeAccount(account['phone']!);
                    await _loadSavedAccounts();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _showPhoneSuggestions(); // Refresh suggestions
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthStorageService.clearAllAccounts();
              await _loadSavedAccounts();
              Navigator.pop(context);
              Navigator.pop(context);
              Get.snackbar(
                'Cleared',
                'All saved accounts have been removed',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Format timestamp for display
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png', height: 40),
                  SizedBox(height: 20),

                  // Main Box
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 12,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                'Login to your account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Phone Field with Multiple Account Suggestions
                              // Phone Field with Multiple Account Suggestions
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Show suggestions when tapping anywhere on the field
                                        if (_savedAccounts.isNotEmpty) {
                                          _showPhoneSuggestions();
                                        }
                                      },
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        readOnly: false, // Keep editable
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(
                                            Icons.phone,
                                            color: AppTheme.primaryColor,
                                          ),
                                          hintText: _savedAccounts.isNotEmpty
                                              ? 'Tap to see ${_savedAccounts.length} saved account(s)'
                                              : 'Enter phone number',
                                          hintStyle: TextStyle(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                          // Add border to make it clear it's tappable
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_savedAccounts.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(left: 8),
                                      child: ElevatedButton(
                                        onPressed: _showPhoneSuggestions,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(12),
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: AppTheme.primaryColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  // Add border to match phone field
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),

                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      Get.toNamed('/forgot-password'),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Login Button
                              Obx(
                                () => ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _authController.isLoading.value
                                      ? SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: LoadingWidget(size: 30),
                                        )
                                      : Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AppTheme.subTitleColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.toNamed('/register'),
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show keyboard suggestions
  void _showKeyboardSuggestions(
    BuildContext context,
    TextEditingController controller,
    List<String> suggestions,
  ) {
    // This will show suggestions in the keyboard area
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.titleColor,
                ),
              ),
            ),
            ...suggestions.map(
              (suggestion) => ListTile(
                leading: Icon(
                  controller == _phoneController ? Icons.phone : Icons.lock,
                  color: AppTheme.primaryColor,
                ),
                title: Text(
                  controller == _phoneController ? suggestion : '••••••••',
                ),
                onTap: () {
                  controller.text = suggestion;
                  Navigator.pop(context);
                  // Focus the next field if it's phone
                  if (controller == _phoneController) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Future.delayed(Duration(milliseconds: 100), () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  }
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
