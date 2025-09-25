import 'package:flutter/material.dart';
import '../../jobs/data/jobs_api.dart';
import '../../jobs/data/jobs_models.dart';
import '../../../design_system.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobsApiClient _api = JobsApiClient();
  JobRecord? _job;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.fetchJobById(widget.jobId);
      final list = (res.data['records'] as List?) ?? [];
      setState(() {
        _job = list.isNotEmpty ? JobRecord.fromJson(list.first) : null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('Not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _job!.title,
                        style: DesignSystem.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_job!.category} • ${_job!.service}',
                        style: DesignSystem.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.attach_money_rounded),
                          const SizedBox(width: 6),
                          Text(_JobPrice.format(_job!)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.place_rounded),
                          const SizedBox(width: 6),
                          Expanded(child: Text(_job!.address)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(_job!.details),

                      if (_job!.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _job!.tags.map((t) => _tag(t)).toList(),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DesignSystem.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: DesignSystem.cardShadow,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_job!.contactName)),
                            const SizedBox(width: 8),
                            Text(_job!.contactPhone),
                          ],
                        ),
                      ),

                      // 👇 schedule block
                      if (_job!.schedule != null) ...[
                        const SizedBox(height: 20),
                        Text("📅 Schedule",
                            style: DesignSystem.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        _buildSchedule(_job!.schedule!),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSchedule(Map<String, dynamic> schedule) {
    final start = schedule['startDate'] ?? '';
    final end = schedule['endDate'] ?? '';
    final type = schedule['scheduleType'] ?? '';
    final specificDates = (schedule['specificDates'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystem.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Type: $type"),
          if (start.isNotEmpty) Text("Start: $start"),
          if (end.isNotEmpty) Text("End: $end"),
          if (specificDates.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Specific Dates:"),
            Wrap(
              spacing: 6,
              children: specificDates.map((d) => Chip(label: Text(d))).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _JobPrice {
  static String format(JobRecord j) {
    if (j.price == 0) return 'Free';
    return '₹${j.price}/${j.pricingType.replaceAll('per_', '')}';
  }
}
