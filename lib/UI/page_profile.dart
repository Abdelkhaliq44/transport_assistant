import 'package:flutter/material.dart';
import 'package:transport_assistant/UI/page_singin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── BACKGROUND IMAGE ──
          SizedBox.expand(
            child: Image.asset(
              'assets/images/photo_2026-05-02_15-51-19.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── DARK OVERLAY ──
         Container(
          color: Colors.black.withOpacity(0.25),
          ),


          Positioned(
            right: 147,
            top:90 ,
            child: CircleAvatar(

            radius: 65,
            backgroundColor: Color(0xFFBECFDF),
            child: Icon(Icons.person, size: 90, color: Color(0xFF1F2E3B)),
          ),
          ),
          Positioned(
            right: 155,
            top:190 ,
            child: GestureDetector(
              child: CircleAvatar(
              
                radius: 10,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, size: 18, color:Color(0xFF1F2E3B)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 190.0),
            child: Column(
              children: [
                const Positioned(
                  top: 80,
                  child: Column(
                    children: [

                      SizedBox(height: 60),
                      Text(
                        'Ali Benyahia Abdelkhaliq',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Algeria',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        _sectionTitle('About'),
                        const SizedBox(height: 10),

                        _buildFieldLabel('Email'),
                        const SizedBox(height: 4),
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          value: 'Abdelkhaliq@gmail.com',
                        ),

                        const SizedBox(height: 12),

                        _buildFieldLabel('Gender'),
                        const SizedBox(height: 4),
                        _buildInfoTile(
                          icon: Icons.male,
                          value: 'Male',
                        ),

                        const SizedBox(height: 24),

                        _sectionTitle('Preferences'),
                        const SizedBox(height: 10),

                        _buildPreferenceTile(
                          icon: Icons.language,
                          label: 'Languages',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'English',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),

                        const SizedBox(height: 4),

                        _buildPreferenceTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (v) =>
                                setState(() => _notificationsEnabled = v),

                            activeColor:const Color(0xFF1F2E3B) , // لون الدائرة كي يكون ON
                            activeTrackColor: const Color(0xFFBECFDF), // الخلفية كي يكون ON

                            inactiveThumbColor: Colors.grey, // الدائرة كي يكون OFF
                            inactiveTrackColor: Colors.grey.shade300, // الخلفية كي يكون OFF
                          ),
                        ),

                        const SizedBox(height: 4),

                        _buildPreferenceTile(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          trailing: Switch(
                            value: _darkModeEnabled,
                            onChanged: (v) =>
                                setState(() => _darkModeEnabled = v),
                            activeColor:const Color(0xFF1F2E3B) , // لون الدائرة كي يكون ON
                            activeTrackColor: const Color(0xFFBECFDF), // الخلفية كي يكون ON

                            inactiveThumbColor: Colors.grey, // الدائرة كي يكون OFF
                            inactiveTrackColor: Colors.grey.shade300, // الخلفية كي يكون OFF
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBECFDF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFF1F2E3B),// ← هنا لون الكتابة
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        decoration: TextDecoration.underline,
        decorationColor: Colors.white,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF263245),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBF7F7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Text(
            'Edit',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

