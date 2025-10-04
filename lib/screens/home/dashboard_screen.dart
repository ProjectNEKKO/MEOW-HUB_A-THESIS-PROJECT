import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Feeding Card
          DashboardCard(
            title: "Feeding",
            subtitle: "Last meal: Today 8:30 AM",
            icon: Icons.restaurant,
            color: Colors.orange,
            onTap: () {
              
            },
          ),
          const SizedBox(height: 12),

          // Hydration Card
          DashboardCard(
            title: "Hydration",
            subtitle: "Water level: 75%",
            icon: Icons.water_drop,
            color: Colors.blue,
            onTap: () {
              
            },
          ),
          const SizedBox(height: 12),

          // Litter Box Card
          DashboardCard(
            title: "Litter Box",
            subtitle: "Last cleaned: Yesterday 6:00 PM",
            icon: Icons.cleaning_services,
            color: Colors.green,
            onTap: () {
              
            },
          ),
          const SizedBox(height: 12),

          // Logs / History Card
          DashboardCard(
            title: "Activity Logs",
            subtitle: "View feeding, hydration, and litter events",
            icon: Icons.history,
            color: Colors.purple,
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withAlpha(40),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
