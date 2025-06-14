import 'package:flutter/material.dart';

// This is a global variable. It can be updated from anywhere.
var appPin = '1234'; // Global PIN value

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

  void _login() {
    if (_pincodeController.text == appPin) {
      // UPDATED: This navigation method ensures a clean stack for the home page.
      // The user won't be able to use the Android back button to get back to the login screen.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 3) {
          _error = 'Too many failed attempts. Login disabled.';
        } else {
          _error = 'Invalid pincode. Attempts left: ${3 - _attempts}';
        }
        _pincodeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                    ),
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

  void _transfer(String recipient, double amount) {
    if (amount > _balance) {
      _showErrorDialog('Insufficient funds!');
      return;
    }

    if (recipient.isEmpty) {
      _showErrorDialog('Please enter a recipient.');
      return;
    }

    setState(() {
      _balance -= amount;
    });

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transfer Successful'),
        content: Text('₱${amount.toStringAsFixed(2)} sent to $recipient.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current PIN',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current PIN';
                  }
                  if (value != appPin) {
                    return 'Incorrect current PIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New PIN',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirm New PIN',
                  counterText: '',
                ),
                validator: (value) {
                  if (value != newPinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                appPin = newPinController.text;

                Navigator.pop(context);

                showDialog(
                  context: this.context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text('PIN changed successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                      )
                    ],
                  ),
                );
              }
            },
            child: const Text('Change'),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Enter amount', prefixText: '₱'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
              Navigator.pop(dialogContext);
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pay Bills'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: billerController,
              decoration: const InputDecoration(labelText: 'Biller Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
              Navigator.pop(dialogContext);
              _payBills(biller, amount);
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transfer Funds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(labelText: 'Recipient Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final recipient = recipientController.text.trim();
              final input = amountController.text.trim();
              if (recipient.isEmpty) {
                _showErrorDialog('Please enter the recipient name.');
                return;
              }
              final amount = double.tryParse(input);
              if (amount == null || amount <= 0) {
                _showErrorDialog('Please enter a valid amount.');
                return;
              }
              Navigator.pop(dialogContext);
              _transfer(recipient, amount);
            },
            child: const Text('Transfer'),
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
        // NEW: This leading button acts as a logout button.
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () {
            // This navigation method returns to a fresh LoginPage and clears all other pages.
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text('My Wallet'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'Change PIN',
            onPressed: _showChangePinDialog,
          ),
        ],
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
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildCard(
                        color: const Color(0xFF546E7A),
                        icon: Icons.send,
                        title: 'Transfer',
                        subtitle: 'Send funds to another person.',
                        onTap: _showTransferDialog,
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