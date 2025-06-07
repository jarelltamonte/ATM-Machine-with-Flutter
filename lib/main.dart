import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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

  void _payBills(double amount) {
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
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Enter amount',
            prefixText: '₱',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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
              color: color.withOpacity(0.6),
              offset: const Offset(0, 6),
              blurRadius: 8,
            )
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card Container
              Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                        color: const Color(0xFF6D8A96),
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
                        color: const Color(0xFFB35A59),
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
                        color: const Color(0xFFBFC9CA),
                        icon: Icons.receipt_long,
                        title: 'Pay Bills',
                        subtitle: 'Pay your bills easily.',
                        onTap: () => _showAmountDialog(
                          title: 'Pay Bills',
                          actionText: 'Pay',
                          onConfirmed: _payBills,
                        ),
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
