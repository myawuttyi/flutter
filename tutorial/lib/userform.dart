import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Test Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyFormPage(), // ဒီနေရာမှာ argument မလိုဘဲ တိုက်ရိုက်ခေါ်နိုင်ပါတယ်
    );
  }
}

// Widget Class နာမည်ကို MyFormPage ဟု ပြောင်းထားပါသည်
class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key});

  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  // Form ရဲ့ state နဲ့ validation ကို ထိန်းချုပ်မယ့် Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submitForm() {
    // validate() လုပ်လိုက်တာနဲ့ TextFormField တွေရဲ့ validator အကုန်လုံးကို စစ်ဆေးပေးပါတယ်
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အောင်မြင်ပါသည်: ${_usernameController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _usernameController.clear();
    _emailController.clear();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Form Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // Flutter မူရင်း Form widget ကို ဤနေရာတွင် စနစ်တကျ သုံးထားပါသည်
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username input with validation
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'အမည်ရိုက်ထည့်ပါ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username ဖြည့်ရန် လိုအပ်ပါသည်';
                  }
                  if (value.trim().length < 3) {
                    return 'အနည်းဆုံး စာလုံး ၃ လုံး ရှိရပါမည်';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email input with validation
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email ဖြည့်ရန် လိုအပ်ပါသည်';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'မှန်ကန်သော Email ဖြစ်ရပါမည်';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit & Reset Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}