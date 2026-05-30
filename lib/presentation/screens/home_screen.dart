import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import 'scanner_screen.dart';
import 'generate_qr_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'auth/auth_choice_screen.dart';

Color _statusColor(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.success:    return const Color(0xFF1B5E5E);
    case TransactionStatus.failed:     return Colors.red;
    case TransactionStatus.pending:
    case TransactionStatus.processing: return const Color(0xFFF5B800);
    case TransactionStatus.refunded:   return Colors.purple;
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006847)),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Chargement de votre profil...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider).signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Retour à l'accueil"),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF006847)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMerchantView = ref.watch(isMerchantViewProvider);
    final bool effectiveIsMerchant = user.isMerchant ? true : isMerchantView;

    final List<Widget> screens = [
      _buildDashboard(context, effectiveIsMerchant),
      effectiveIsMerchant ? const GenerateQRScreen() : const ScannerScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context, effectiveIsMerchant),
    );
  }

  Widget _buildDashboard(BuildContext context, bool isMerchant) {
    final user = ref.watch(userProvider)!;
    final transactionsAsync = ref.watch(transactionsProvider);
    final walletAsync = ref.watch(defaultWalletProvider);
    final statsAsync = isMerchant ? ref.watch(merchantStatsProvider) : null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMerchant ? 'Espace Marchand' : 'Bonjour,',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            user.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null ? const Icon(Icons.person) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildBalanceCard(context, walletAsync, statsAsync, isMerchant),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Actions Rapides"),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Activité Récente"),
                  const SizedBox(height: 16),
                  transactionsAsync.when(
                    data: (transactions) => _buildRecentActivity(transactions, user.id),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Erreur: $e'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    AsyncValue<WalletModel?> walletAsync,
    AsyncValue? statsAsync,
    bool isMerchant,
  ) {
    final primaryColor = isMerchant ? const Color(0xFFF59E0B) : const Color(0xFF059669);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMerchant ? "Revenus total" : "Solde disponible",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(LucideIcons.wallet, color: Colors.white.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          if (isMerchant && statsAsync != null)
            statsAsync.when(
              data: (stats) => _balanceText((stats as dynamic).formattedRevenue),
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => _balanceText('— XOF'),
            )
          else
            walletAsync.when(
              data: (wallet) => _balanceText(wallet?.formattedBalance ?? '0 XOF'),
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => _balanceText('— XOF'),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _selectedIndex = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              isMerchant ? "Générer un QR Code" : "Scanner pour Payer",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.5),
        ),
        const Text("Voir tout", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(LucideIcons.send, "Envoyer", Colors.blue),
        _actionItem(LucideIcons.download, "Recevoir", Colors.orange),
        _actionItem(LucideIcons.layoutGrid, "Services", Colors.purple),
        _actionItem(LucideIcons.moreHorizontal, "Plus", const Color(0xFF64748B)),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildRecentActivity(List<TransactionModel> transactions, String currentUserId) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Aucune activité récente", style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length > 5 ? 5 : transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isOutgoing = tx.senderId == currentUserId;
          final statusColor = _statusColor(tx.status);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOutgoing ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOutgoing ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                size: 20,
                color: isOutgoing ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
              ),
            ),
            title: Text(tx.reference, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(
              DateFormat('dd MMM, HH:mm').format(tx.createdAt),
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isOutgoing ? '-' : '+'}${tx.formattedAmount}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isOutgoing ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                  ),
                ),
                Text(tx.statusLabel, style: TextStyle(fontSize: 10, color: statusColor)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isMerchant) {
    final activeColor = isMerchant ? const Color(0xFFF59E0B) : const Color(0xFF059669);

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(LucideIcons.home, "Accueil", 0, activeColor),
          _navItem(isMerchant ? LucideIcons.qrCode : LucideIcons.scan, isMerchant ? "QR" : "Scanner", 1, activeColor),
          _navItem(LucideIcons.history, "Historique", 2, activeColor),
          _navItem(LucideIcons.settings, "Réglages", 3, activeColor),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, Color activeColor) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? activeColor : const Color(0xFFCBD5E1), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}
