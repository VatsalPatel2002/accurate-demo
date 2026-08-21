import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/authentication_controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = AppControllers.login;
  static const routeName = '/login';
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Large half-circle background covering 50% of the screen
          Positioned(
            right: -screenWidth * 1.1,
            top: -screenHeight * 0.6,
            child: Container(
              width: screenWidth * 1.9,
              height: screenHeight * 1.4,
              decoration: const BoxDecoration(
                color: Color(0xFFb2ebe3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content of the login page
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Company Logo
                Image.asset(
                  'assets/logo.png', // Your ACCURATE company logo path
                  height: screenHeight * 0.15, // Responsive logo height
                  width: screenWidth * 0.4, // Responsive logo width
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.05),

                // Welcome Text
                Text(
                  "Welcome!\n To ACCURATE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.035, // Responsive text size
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF034255),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Username TextField
                TextField(
                  onChanged: (val) => controller.username.value = val,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Username / User ID",
                    labelStyle: TextStyle(color: Color(0xFF034255)),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: Color(0xFF034255),
                          width: 2.0), // Black border when focused
                    ),
                  ),
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Password TextField with visibility toggle
                Obx(() => TextField(
                      onChanged: (val) => controller.password.value = val,
                      obscureText: controller.isPasswordHidden.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Color(0xFF034255)),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(controller.isPasswordHidden.value
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            controller.isPasswordHidden.value =
                                !controller.isPasswordHidden.value;
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Color(0xFF034255),
                              width: 2.0), // Black border when focused
                        ),
                      ),
                      style: TextStyle(fontSize: screenHeight * 0.02),
                    )),
                Obx(
                  () => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.012),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Forgot password text
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password recovery is unavailable in demo mode.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: Color(0xFF034255),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Login Button
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF034255),
                      disabledBackgroundColor: const Color(0xFF034255),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded button
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: screenHeight * 0.025,
                            height: screenHeight * 0.025,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: screenHeight * 0.025,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // "Don't have an account?" Text with Sign Up
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Account registration is unavailable in demo mode.',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF034255),
                          fontSize: screenHeight * 0.018,
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
    );
  }
}
