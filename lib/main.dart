import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_page.dart'; // Update this import based on the file's location
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fast Tag Form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: const AuthCheck(),
      // Check the authentication state on startup
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return const WelcomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text == 'bkaccfastag' &&
          _passwordController.text == 'bkaccanmol') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsPage(),
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.cyanAccent.withOpacity(0.6),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/logo.png'),
                              fit: BoxFit.contain,
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _navigateToAboutUs,
                              child: const Text('About Us'),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: _navigateToPrivacyPolicy,
                              child: const Text('Privacy Policy'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// About Us Page
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: const Text(
            'WORLD RENEWAL SPIRITUAL TRUST (WRST) is a Non-Governmental Organization (NGO) / Voluntary Organization (VO) / Non Profit Organisation (NPO). '
            'A non-profit organization that operates independently of any government, typically one whose purpose is to address a social or political issue.\n\n'
            'Registered as a charitable trust, with its Head-Office in Mumbai, the WRST was incorporated in December 1968 with our main services including arrangement and management of museums, '
            'exhibitions and seminars with special emphasis on imparting knowledge, ennobling character & uplifting human lives. For this purpose, the WRST makes provisions for the study and teaching as '
            'also establishing and managing institutes for the said purpose.',
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}

// Privacy Policy Page

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blueAccent, // Updated color for a modern look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Position of shadow
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Privacy Policy for Fastag App',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10), // Spacing between sections
                Text(
                  'At https://bkaccanmol.bkapp.org/ Fastag App, we are committed to protecting the privacy of our users. This Privacy Policy outlines how we collect, '
                  'use, and safeguard your personal information when you use our mobile application.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Information We Collect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'At bkaccanmol, accessible from https://bkaccanmol.bkapp.org/, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by bkaccanmol and how we use it.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'How We Use Your Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'The information we collect is used for providing and improving our services, ensuring secure access, and responding to your inquiries. '
                  'We may also use your information to send notifications or manage your requests.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Data Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'We take steps to protect your information from unauthorized access or disclosure, but no method of data transmission is completely secure.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Children’s Privacy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'We do not knowingly collect personal information from children under 13. If we become aware that we have collected such information, '
                  'we will take immediate steps to delete it.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Changes to the Privacy Policy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'We may update this Privacy Policy from time to time. If any material changes are made, we will notify you through the app.\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'For any questions or concerns regarding our privacy practices, please contact us at hqaccounts@bkivv.org.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
