import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import 'scanner_screen.dart';
import 'generate_qr_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isMerchant = authProvider.isMerchant;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Liste des écrans pour chaque onglet
    final List<Widget> screens = [
      _buildDashboard(context, user, isMerchant),
      isMerchant ? const GenerateQRScreen() : const ScannerScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context, isMerchant),
    );
  }

  Widget _buildDashboard(BuildContext context, user, bool isMerchant) {
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
                            'Bonjour,',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildBalanceCard(context, user, isMerchant),
                  const SizedBox(height: 32),
                  _buildSectionHeader(isMerchant ? "Outils Marchand" : "Actions Rapides"),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, isMerchant),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Activité Récente"),
                  const SizedBox(height: 16),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, user, bool isMerchant) {
    final primaryColor = isMerchant ? const Color(0xFFF59E0B) : const Color(0xFF059669);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                isMerchant ? "Revenus du jour" : "Solde disponible",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              Icon(LucideIcons.wallet, color: Colors.white.withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                user.balance.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                "FCFA",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Switch to Scan/QR tab
              });
            },
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

  Widget _buildQuickActions(BuildContext context, bool isMerchant) {
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.shoppingBag, size: 20, color: Color(0xFF64748B)),
            ),
            title: const Text("Supermarché Erevan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text("Aujourd'hui, 14:20", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            trailing: const Text("-4.500 F", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isMerchant) {
    final activeColor = isMerchant ? const Color(0xFFF59E0B) : const Color(0xFF059669);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
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
