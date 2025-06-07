import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatters

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATM Machine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3A4A), // Muted blue-gray
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8), // Light matte background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3A4A), // Matte blue-gray
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pincodeController = TextEditingController();
  String _pincode = '';
  int _attempts = 0;
  final int _maxAttempts = 3;
  void _login() {
    setState(() {
      if (_attempts >= _maxAttempts) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum attempts reached. Please try again later.'),
          ),
        );
        return;
      }
      _pincode = _pincodeController.text;
      if (_pincode == '1234') {
        _attempts = 0;
        // Credentials match, show modal dialog
        _showLoginSuccessDialog();
      } else {
        _attempts++;
        int remaining = _maxAttempts - _attempts;
        // Credentials do not match, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid Pincode!\nPincode: $_pincode\nAttempts left: $remaining',
            ),
          ),
        );
      }
    });
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to proceed
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('You have successfully logged in!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement( // Use pushReplacement to prevent going back to login
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              color: const Color(0xFFE9ECEF), // Matte light card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.lock_outline, size: 60, color: Color(0xFF2D3A4A)),
                    const SizedBox(height: 20),
                    Text(
                      'ATM Login',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3A4A),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _pincodeController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.pin, color: Color(0xFF2D3A4A)),
                        counterText: '',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: const Color(0xFF4F5D75), // Muted blue
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _balance = 100000.00;

  void _showDepositDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deposit Funds'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₱',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  setState(() {
                    _balance += amount;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully deposited ₱${amount.toStringAsFixed(2)}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Deposit'),
            ),
          ],
        );
      },
    );
  }

  void _showPayBillsDialog() {
    final TextEditingController billerController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pay Bills'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: billerController,
                decoration: const InputDecoration(
                  labelText: 'Biller Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₱',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(amountController.text);
                final String biller = billerController.text;

                if (biller.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a biller name.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (amount == null || amount <= 0) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (amount > _balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient funds.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  setState(() {
                    _balance -= amount;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully paid ₱${amount.toStringAsFixed(2)} to $biller.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              color: const Color(0xFF4F5D75), // Muted blue
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Balance: ₱${_balance.toStringAsFixed(2)}', // Use state variable
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This is your current balance. Please select an option below.', // Updated text
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showDepositDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      color: const Color(0xFF6D8A96), // Muted teal
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                            SizedBox(height: 10),
                            Text(
                              'Deposit',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Deposit funds to your account.',
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _showPayBillsDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      color: const Color(0xFFBFC9CA), // Matte gray
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Icon(Icons.receipt_long, color: Color(0xFF2D3A4A), size: 32),
                            SizedBox(height: 10),
                            Text(
                              'Pay Bills',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3A4A),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Pay your bills easily.',
                              style: TextStyle(fontSize: 16, color: Color(0xFF4F5D75)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}