import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';

class RecentsTab extends StatefulWidget {
  const RecentsTab({super.key});

  @override
  State<RecentsTab> createState() => _RecentsTabState();
}

class GroupedCallLog {
  final CallLogEntry entry;
  int count;

  GroupedCallLog(this.entry, {this.count = 1});
}

class _RecentsTabState extends State<RecentsTab> {
  Future<Iterable<CallLogEntry>>? _callLogFuture;

  @override
  void initState() {
    super.initState();
    _refreshCallLog();
  }

  void _refreshCallLog() {
    setState(() {
      _callLogFuture = CallLog.get();
    });
  }

  Future<void> _makeCall(String? number) async {
    if (number == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  List<GroupedCallLog> _groupCalls(List<CallLogEntry> entries) {
    if (entries.isEmpty) return [];

    List<GroupedCallLog> grouped = [];
    
    // Start with the first entry
    grouped.add(GroupedCallLog(entries.first));

    for (int i = 1; i < entries.length; i++) {
      final current = entries[i];
      final lastGroup = grouped.last;
      final lastEntry = lastGroup.entry;

      // Check if same number and same call type (optional, usually dialers group by number regardless of type, 
      // but strictly "consecutive calls from same number" is the standard).
      // We will group by Number ONLY to mimic standard behavior for "consecutive interactions".
      // Some dialers break group if type is different (missed vs outgoing). 
      // Let's stick to: Same Number = Group.
      
      // Normalize numbers (strip formatting if needed, but usually raw is fine)
      bool isSameNumber = current.number == lastEntry.number;
      
      if (isSameNumber) {
        lastGroup.count++;
      } else {
        grouped.add(GroupedCallLog(current));
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return FutureBuilder<Iterable<CallLogEntry>>(
      future: _callLogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recent calls'));
        }

        var entries = snapshot.data!.toList();

        // Apply History Limit
        if (entries.length > settings.historyLimit) {
          entries = entries.sublist(0, settings.historyLimit);
        }

        List<dynamic> displayList; // Can be CallLogEntry or GroupedCallLog
        
        if (settings.groupCalls) {
          displayList = _groupCalls(entries);
        } else {
          displayList = entries;
        }

        return ListView.separated(
          itemCount: displayList.length,
          separatorBuilder: (context, index) => settings.showDividers 
              ? const Divider(height: 1) 
              : const SizedBox.shrink(),
          itemBuilder: (context, index) {
            final item = displayList[index];
            
            CallLogEntry entry;
            int count = 1;

            if (item is GroupedCallLog) {
              entry = item.entry;
              count = item.count;
            } else {
              entry = item as CallLogEntry;
            }

            final isMissed = entry.callType == CallType.missed;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: settings.primaryColor.withOpacity(0.1),
                child: Icon(
                  _getCallIcon(entry.callType),
                  color: isMissed ? Colors.red : settings.primaryColor,
                  size: 20,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.name ?? entry.number ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: isMissed ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (count > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Row(
                children: [
                  if (entry.simDisplayName != null || entry.phoneAccountId != null) ...[
                    Icon(Icons.sim_card, size: 12, color: settings.simColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _formatDateTime(entry.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (entry.duration != null && entry.duration! > 0) ...[
                     const SizedBox(width: 8),
                     Text(
                       '(${_formatDuration(entry.duration!)})',
                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
                     ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                color: settings.primaryColor,
                onPressed: () => _makeCall(entry.number),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCallIcon(CallType? type) {
    switch (type) {
      case CallType.incoming: return Icons.call_received;
      case CallType.outgoing: return Icons.call_made;
      case CallType.missed: return Icons.call_missed;
      case CallType.rejected: return Icons.call_end;
      case CallType.blocked: return Icons.block;
      default: return Icons.call;
    }
  }

  String _formatDateTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (diff.inDays < 7) {
      return DateFormat.E().add_jm().format(date);
    } else {
      return DateFormat.yMMMd().add_jm().format(date);
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }
  }
}
