import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/purchase_record.dart';
import '../services/admin_auth_service.dart';
import '../utils/portfolio_theme.dart';

/// Admin page to verify payments: list pending purchases and approve or reject.
/// Access is gated by Firestore `superadmin` collection (username + passwordHash).
class PurchaseAdminPage extends StatelessWidget {
  const PurchaseAdminPage({super.key});

  static const String _collection = 'purchases';
  static final _adminAuth = AdminAuthService();

  /// Shows login dialog; returns true if credentials match a superadmin document.
  static Future<bool> checkCredentials(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AdminLoginDialog(authService: _adminAuth),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment verification'),
        backgroundColor: PortfolioTheme.accentPrimary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No purchases yet. They will appear here when customers submit a transaction ID.'),
            );
          }
          final pending = docs.where((d) => (d.data()['status'] as String? ?? '') == 'pending').toList();
          final others = docs.where((d) => (d.data()['status'] as String? ?? '') != 'pending').toList();
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              if (pending.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Pending — verify payment then Approve or Reject',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                ),
                ...pending.map((d) => _PurchaseCard(
                      doc: d,
                      onApprove: () => _updateStatus(context, d.reference, 'verified'),
                      onReject: () => _updateStatus(context, d.reference, 'rejected'),
                    )),
                const SizedBox(height: 24),
              ],
              if (others.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Verified / Rejected',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...others.map((d) => _PurchaseCard(doc: d)),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
    String status,
  ) async {
    try {
      await ref.update({
        'status': status,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'verified' ? 'Approved. Customer can now check status and download.' : 'Rejected.'),
            backgroundColor: status == 'verified' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.doc,
    this.onApprove,
    this.onReject,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final record = PurchaseRecord.fromFirestore(doc);
    final isPending = record.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.transactionId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                _StatusChip(status: record.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('App: ${record.appName}', style: Theme.of(context).textTheme.titleSmall),
            Text('৳${record.amountBdt} · ${record.paymentMethod}', style: Theme.of(context).textTheme.bodySmall),
            if (record.email != null && record.email!.isNotEmpty)
              Text('Email: ${record.email}', style: Theme.of(context).textTheme.bodySmall),
            if (record.createdAt != null)
              Text(
                'Submitted: ${record.createdAt!.toIso8601String().substring(0, 19).replaceFirst('T', ' ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            if (record.isVerified && record.verifiedAt != null)
              Text(
                'Verified: ${record.verifiedAt!.toIso8601String().substring(0, 19).replaceFirst('T', ' ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            if (isPending && onApprove != null && onReject != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'verified':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _AdminLoginDialog extends StatefulWidget {
  const _AdminLoginDialog({required this.authService});

  final AdminAuthService authService;

  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter username and password');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await widget.authService.verifyAdmin(username: username, password: password);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Invalid username or password';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Login failed. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin login'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _login(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _login,
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Login'),
        ),
      ],
    );
  }
}
