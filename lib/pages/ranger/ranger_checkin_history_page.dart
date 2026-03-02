import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 
import 'package:kangnok/providers/checkin_history_provider.dart';
import 'package:kangnok/providers/ranger_profile_provider.dart';

class RangerCheckInHistoryPage extends ConsumerWidget {
  const RangerCheckInHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ดึงข้อมูล Ranger เพื่อเอา parkId
    final rangerAsync = ref.watch(rangerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Check-In History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
            ),
          ),
        ),
      ),
      body: rangerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (ranger) {
          if (ranger == null) return const Center(child: Text("No Ranger Data"));

          // 2. ดึงประวัติการเช็คอินของอุทยานนี้
          final historyAsync = ref.watch(checkInHistoryProvider(ranger.parkId));

          return historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final timestamp = item['checkInTime'] as Timestamp?;
                  final dateStr = timestamp != null 
                      ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                      : 'Recently';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        backgroundImage: item['userPhoto'] != null ? NetworkImage(item['userPhoto']) : null,
                        child: item['userPhoto'] == null ? const Icon(Icons.person, color: Colors.indigo) : null,
                      ),
                      title: Text(
                        item['userName'] ?? 'Unknown Explorer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No check-ins yet",
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text("Explorer's visits will appear here.", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}