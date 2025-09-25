import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../design_system.dart';
import '../../jobs/data/jobs_api.dart';
import '../../jobs/data/jobs_models.dart';
import '../../jobs/data/location_provider.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final JobsApiClient _api = JobsApiClient();
  late final Box<String> _watchBox;
  List<JobRecord> _watchedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive().then((_) => _loadWatchedJobs());
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _watchBox = await Hive.openBox<String>('watchlist');
  }

  Future<void> _loadWatchedJobs() async {
    setState(() => _isLoading = true);

    try {
      final watchedJobIds = _watchBox.keys.toList();
      if (watchedJobIds.isEmpty) {
        setState(() {
          _watchedJobs = [];
          _isLoading = false;
        });
        return;
      }

      final List<JobRecord> jobs = [];
      for (final jobId in watchedJobIds) {
        try {
          final response = await _api.fetchJobById(jobId);
          if (response.statusCode == 200) {
            final jobData = response.data;
            if (jobData != null) {
              jobs.add(JobRecord.fromJson(jobData));
            }
          }
        } catch (e) {
          // Remove invalid job ID from watchlist
          _watchBox.delete(jobId);
        }
      }

      setState(() {
        _watchedJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _removeFromWatchlist(String jobId) {
    _watchBox.delete(jobId);
    setState(() {
      _watchedJobs.removeWhere((job) => job.id == jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundLighter,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Watchlist', style: DesignSystem.textTheme.headlineMedium),
            Consumer(
              builder: (context, ref, child) {
                final locationState = ref.watch(locationProvider);
                return Text(
                  locationState.locationName,
                  style: DesignSystem.textTheme.bodySmall?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final locationState = ref.watch(locationProvider);
              return IconButton(
                icon: Icon(
                  locationState.lat == null ? Icons.location_off : Icons.clear,
                ),
                onPressed: locationState.lat == null
                    ? null
                    : () {
                        ref.read(locationProvider.notifier).clearLocation();
                      },
                tooltip: locationState.lat == null
                    ? 'No location set'
                    : 'Clear location',
              );
            },
          ),
          if (_watchedJobs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadWatchedJobs,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watchedJobs.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadWatchedJobs,
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignSystem.spacing16),
                itemCount: _watchedJobs.length,
                itemBuilder: (context, index) {
                  final job = _watchedJobs[index];
                  return _buildWatchedJobCard(job);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: DesignSystem.textSecondary,
          ),
          SizedBox(height: DesignSystem.spacing16),
          Text(
            'No saved jobs yet',
            style: TextStyle(fontSize: 18, color: DesignSystem.textPrimary),
          ),
          SizedBox(height: DesignSystem.spacing8),
          Text(
            'Jobs you save will appear here',
            style: TextStyle(fontSize: 14, color: DesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchedJobCard(JobRecord job) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      color: DesignSystem.backgroundLight,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/job_details', arguments: job.id);
        },
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: DesignSystem.textTheme.titleLarge,
                        ),
                        const SizedBox(height: DesignSystem.spacing4),
                        Text(
                          '${job.category} • ${job.service}',
                          style: DesignSystem.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: DesignSystem.accentColor,
                    ),
                    onPressed: () => _removeFromWatchlist(job.id),
                    tooltip: 'Remove from watchlist',
                  ),
                  Text(
                    _formatPrice(job),
                    style: DesignSystem.textTheme.titleMedium?.copyWith(
                      color: DesignSystem.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spacing8),
              Text(
                job.details,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: DesignSystem.textTheme.bodyMedium,
              ),
              const SizedBox(height: DesignSystem.spacing8),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16),
                  const SizedBox(width: DesignSystem.spacing4),
                  Expanded(
                    child: Text(
                      job.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignSystem.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (job.tags.isNotEmpty) ...[
                const SizedBox(height: DesignSystem.spacing8),
                Wrap(
                  spacing: DesignSystem.spacing8,
                  runSpacing: DesignSystem.spacing4,
                  children: job.tags
                      .take(3)
                      .map((tag) => _buildTag(tag))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing8,
        vertical: DesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
      ),
      child: Text(label, style: DesignSystem.textTheme.bodySmall),
    );
  }

  String _formatPrice(JobRecord job) {
    if (job.price == 0) return 'Free';
    return '₹${job.price}/${job.pricingType.replaceAll('per_', '')}';
  }
}
