import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart'; 
import '../../controllers/farmer/auth_controller.dart'; 
// Ensure the path '../../controllers/farmer/auth_controller.dart' is correct
// If not, adjust the import.

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // 🔑 Get the AuthController instance
  final AuthController authController = Get.find<AuthController>();

  // Role State: [Veteran, Farmer]
  List<bool> _selected = [true, false]; 
  
  // Text Controllers
  final TextEditingController _phoneController = TextEditingController(); // 🔑 Changed from email
  final TextEditingController _passwordController = TextEditingController();

  // Helper colors/asset based on selection (Veteran is Index 0, Farmer is Index 1)
  Color get _veteranColor => const Color(0xFF191C32); // Assuming old Admin/Screen1 color
  Color get _farmerColor => const Color.fromRGBO(70, 49, 29, 1); // Assuming old Student/Screen2 color
  
  Color get _primaryColor => _selected[0] ? _veteranColor : _farmerColor;
  String get _assetPath => _selected[0] ? "assets/screen1.png" : "assets/screen2.png";
  
  // Helper for input decoration color (Using the original logic for visual distinction)
  Color get _prefixBgColor => _selected[0] ? const Color(0xFFFFF6DF) : const Color(0xFFDEF5E9);
  Color get _prefixIconColor => _selected[0] ? const Color(0xFFFFCA3A) : const Color(0xFF5FC88F);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // 1. Validate input (Phone number validation is simple here)
    if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter phone number and password');
      return;
    }
    
    // 2. Set controller values (Note: we use 'phone' field now)
    authController.phone.value = _phoneController.text.trim();
    authController.password.value = _passwordController.text.trim();
    
    // Determine the role for the controller logic
    final String role = _selected[0] ? 'veteran' : 'farmer';

    // 3. Call the AuthController's login method, passing the role
    await authController.login(role: role);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  InputDecoration _myDecoration(String hintText, IconData youricon) {
    // ... (InputDecoration logic remains the same, using the dynamic colors)
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _prefixBgColor, shape: BoxShape.circle),
        child: Icon(
          size: 20,
          youricon,
          color: _prefixIconColor,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        borderSide: BorderSide(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        body: Obx(() {
            final bool isLoading = authController.isLoading.value; 

            return ListView(
              children: [
                const SizedBox(height: 20),
                // Toggle at top-left
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(30),
                      fillColor: _primaryColor, 
                      selectedColor: Colors.white,
                      color: Colors.black,
                      isSelected: _selected,
                      onPressed: isLoading ? null : (int index) { 
                        setState(() {
                          _selected[0] = index == 0; // Veteran
                          _selected[1] = index == 1; // Farmer
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Veteran"), // 🔑 Renamed from Admin
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Farmer"), // 🔑 Renamed from Student
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Image.asset(_assetPath, height: 330),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "LOGIN",
                      selectionColor: Color(0xFF1D1049),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
                
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: [
                      // 🔑 PHONE NUMBER INPUT
                      TextField(
                        controller: _phoneController,
                        cursorColor: const Color(0xFF1D1049),
                        obscureText: false,
                        enabled: !isLoading, 
                        keyboardType: TextInputType.phone, // 🔑 Changed to phone keyboard
                        decoration: _myDecoration("Phone Number", FontAwesomeIcons.phone), // 🔑 Changed icon/hint
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 10),
                      // PASSWORD INPUT
                      TextField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFF1D1049),
                        obscureText: true,
                        enabled: !isLoading, 
                        decoration: _myDecoration("Password", FontAwesomeIcons.lock), 
                        onSubmitted: (_) => _handleLogin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return _primaryColor.withOpacity(0.6);
                          }
                          return _primaryColor;
                        },
                      ),
                      fixedSize: const WidgetStatePropertyAll(Size.fromHeight(55)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : () => _showForgotPasswordDialog(),
                    child: Text(
                      "FORGOT PASSWORD?",
                      style: TextStyle(
                        color: isLoading ? _primaryColor.withOpacity(0.6) : _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : () => Get.toNamed('/signup'),
                    child: Text(
                      "NEW USER? SIGN UP",
                      style: TextStyle(
                        color: isLoading ? _primaryColor.withOpacity(0.6) : _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    // ... (Dialog logic, using Get.back())
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your registered phone number or email to reset your password:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Phone/Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showSnackBar('Password reset functionality not implemented yet');
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }
}