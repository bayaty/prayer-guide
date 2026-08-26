import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../services/update_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UpdateInfo? _info;
  bool _checking = false;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final info = await UpdateService.check();
    if (!mounted) return;
    setState(() {
      _info = info;
      _checking = false;
    });
  }

  Future<void> _install() async {
    final url = _info?.apkUrl;
    if (url == null) return;

    setState(() {
      _downloading = true;
      _progress = 0;
    });

    final err = await UpdateService.downloadAndInstall(
      url,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;
    setState(() => _downloading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red[400]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚙️', style: TextStyle(fontSize: 46)),
                      SizedBox(height: 4),
                      Text(
                        'App info and updates',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.translate,
                                color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Step Text',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose what to show with each supplication.',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        AnimatedBuilder(
                          animation: AppSettings.instance,
                          builder: (context, _) {
                            final s = AppSettings.instance;
                            return Column(
                              children: [
                                _TextSwitch(
                                  label: 'Arabic',
                                  value: s.showArabic,
                                  onChanged: s.setShowArabic,
                                ),
                                _TextSwitch(
                                  label: 'Transliteration',
                                  value: s.showTransliteration,
                                  onChanged: s.setShowTransliteration,
                                ),
                                _TextSwitch(
                                  label: 'Translation',
                                  value: s.showTranslation,
                                  onChanged: s.setShowTranslation,
                                ),
                                if (s.hideAllText) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.tintBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.softPink),
                                    ),
                                    child: Text(
                                      'All three are hidden, so steps show '
                                      'only their instructions.',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey[800]),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.system_update,
                                color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'App Updates',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _row('Installed version',
                            info?.currentVersion ?? '…'),
                        const SizedBox(height: 8),
                        _row(
                          'Latest release',
                          _checking
                              ? 'checking…'
                              : (info?.latestVersion ?? 'unknown'),
                        ),

                        if (info?.error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.tintBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.softPink),
                            ),
                            child: Text(
                              info!.error!,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[800]),
                            ),
                          ),
                        ],

                        if (info != null &&
                            info.error == null &&
                            !info.updateAvailable &&
                            !_checking) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[600], size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'You are up to date',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ],

                        if (info?.updateAvailable == true) ...[
                          const SizedBox(height: 14),
                          Text(
                            'Version ${info!.latestVersion} is available.',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                          if ((info.releaseNotes ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              info.releaseNotes!.trim(),
                              style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: Colors.grey[700]),
                            ),
                          ],
                        ],

                        if (_downloading) ...[
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            backgroundColor: AppColors.softPink,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _progress > 0
                                ? 'Downloading… ${(_progress * 100).toStringAsFixed(0)}%'
                                : 'Downloading…',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],

                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: (_checking || _downloading)
                                ? null
                                : (info?.updateAvailable == true
                                    ? _install
                                    : _check),
                            icon: Icon(
                              info?.updateAvailable == true
                                  ? Icons.download
                                  : Icons.refresh,
                              size: 20,
                            ),
                            label: Text(
                              info?.updateAvailable == true
                                  ? 'Update now'
                                  : (_checking
                                      ? 'Checking…'
                                      : 'Check for updates'),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Updates are downloaded from GitHub Releases.\n'
                    'Android will ask permission to install.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ],
    );
  }
}


/// A compact labelled switch used by the step-text settings.
class _TextSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TextSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: AppColors.accent,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
