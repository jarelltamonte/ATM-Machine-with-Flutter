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
      title: 'Pincode Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
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
  int _attempts = 0;
  String? _error;
  final String _correctPincode = '1234';

  void _login() {
    if (_pincodeController.text == _correctPincode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 3) {
          _error = 'Too many failed attempts. Login disabled.';
        } else {
          _error = 'Invalid pincode. Attempts left: ${3 - _attempts}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.blueGrey[700]),
                const SizedBox(height: 16),
                const Text(
                  'Enter Pincode',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A4A),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  enabled: _attempts < 3,
                  decoration: InputDecoration(
                    labelText: '4-digit Pincode',
                    border: const OutlineInputBorder(),
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.pin,
                      color: Colors.blueGrey[700],
                    ), // Added icon
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _attempts >= 3 ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
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
  double _balance = 1000.0;

  void _deposit(double amount) {
    setState(() {
      _balance += amount;
    });
    Navigator.pop(context);
  }

  void _withdraw(double amount) {
    if (amount > _balance) {
      _showErrorDialog('Insufficient funds!');
      return;
    }
    setState(() {
      _balance -= amount;
    });
    Navigator.pop(context);
  }

  void _payBills(String biller, double amount) {
    if (amount > _balance) {
      _showErrorDialog('Insufficient funds!');
      return;
    }
    setState(() {
      _balance -= amount;
    });
    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showAmountDialog({
    required String title,
    required String actionText,
    required Function(double) onConfirmed,
  }) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                prefixText: '₱',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final input = controller.text.trim();
                  if (input.isEmpty) return;

                  final amount = double.tryParse(input);
                  if (amount == null || amount <= 0) {
                    _showErrorDialog('Please enter a valid positive number.');
                    return;
                  }

                  onConfirmed(amount);
                },
                child: Text(actionText),
              ),
            ],
          ),
    );
  }

  void _showPayBillsDialog() {
    final TextEditingController billerController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final biller = billerController.text.trim();
              final input = amountController.text.trim();
              if (biller.isEmpty) {
                _showErrorDialog('Please enter the biller name.');
                return;
              }
              if (input.isEmpty) return;
              final amount = double.tryParse(input);
              if (amount == null || amount <= 0) {
                _showErrorDialog('Please enter a valid positive number.');
                return;
              }
              _payBills(biller, amount);
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blueGrey[50],
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${_balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        color: const Color(0xFF607D8B),
                        icon: Icons.account_balance_wallet,
                        title: 'Deposit',
                        subtitle: 'Deposit funds to your account.',
                        onTap: () => _showAmountDialog(
                          title: 'Deposit Funds',
                          actionText: 'Deposit',
                          onConfirmed: _deposit,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildCard(
                        color: const Color(0xFF789262),
                        icon: Icons.money_off,
                        title: 'Withdraw',
                        subtitle: 'Withdraw funds from your account.',
                        onTap: () => _showAmountDialog(
                          title: 'Withdraw Funds',
                          actionText: 'Withdraw',
                          onConfirmed: _withdraw,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildCard(
                        color: const Color(0xFF90A4AE),
                        icon: Icons.receipt_long,
                        title: 'Pay Bills',
                        subtitle: 'Pay your bills easily.',
                        onTap: _showPayBillsDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
