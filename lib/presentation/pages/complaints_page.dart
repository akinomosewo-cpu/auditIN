import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/power_repository_impl.dart';
import '../../domain/entities/power_log.dart';
import '../../domain/services/complaint_letter_generator.dart';
import '../../domain/usecases/power_usecases.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  static const _generator = ComplaintLetterGenerator();

  bool _generating = false;
  List<Complaint> _complaints = const [];
  bool _loadingComplaints = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  PowerRepositoryImpl get _repository => context.read<PowerRepositoryImpl>();

  Future<void> _loadComplaints() async {
    setState(() => _loadingComplaints = true);
    final result = await _repository.getComplaints();
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _complaints = const [];
        _loadingComplaints = false;
      }),
      (complaints) => setState(() {
        _complaints = complaints;
        _loadingComplaints = false;
      }),
    );
  }

  Future<void> _generateComplaint() async {
    setState(() => _generating = true);
    final useCase = GenerateComplaintUseCase(_repository);
    final result = await useCase(days: 30);

    if (!mounted) return;
    setState(() => _generating = false);

    result.fold(
      (failure) => _showSnack(failure.message, isError: true),
      (complaint) async {
        await _repository.saveComplaint(complaint);
        await _loadComplaints();
        if (!mounted) return;
        final profileResult = await _repository.getUserProfile();
        profileResult.fold(
          (failure) => _showSnack(failure.message, isError: true),
          (profile) {
            if (profile == null) {
              _showSnack('Add your profile details in Settings first.',
                  isError: true);
              return;
            }
            _openLetterPreview(complaint, profile);
          },
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
      ),
    );
  }

  void _openLetterPreview(Complaint complaint, UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LetterPreviewPage(
          complaint: complaint,
          profile: profile,
          generator: _generator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complaints',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generate button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description_outlined,
                        color: Colors.white, size: 28),
                    const Gap(12),
                    Text(
                      'Generate Complaint Letter',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      'Based on your last 30 days of verified supply data, auto-generate a '
                      'formal complaint to AEDC or NERC.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: _generating ? null : _generateComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: _generating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generate Now'),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              Text(
                'Contact Info',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(12),

              const _ContactCard(
                title: 'AEDC Customer Care',
                subtitle: AppConstants.aedcComplaintEmail,
                phone: AppConstants.aedcPhone,
                icon: Icons.business_outlined,
              ),

              const Gap(12),

              const _ContactCard(
                title: 'NERC (Regulator)',
                subtitle: AppConstants.nercEmail,
                phone: AppConstants.nercPhone,
                icon: Icons.gavel_outlined,
              ),

              const Gap(24),

              Text(
                'Your Complaints',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(12),

              if (_loadingComplaints)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_complaints.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          color: AppColors.textTertiary,
                          size: 40,
                        ),
                        const Gap(12),
                        Text(
                          'No complaints yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._complaints.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ComplaintTile(
                      complaint: c,
                      onTap: () async {
                        final profileResult = await _repository.getUserProfile();
                        profileResult.fold(
                          (failure) => _showSnack(failure.message, isError: true),
                          (profile) {
                            if (profile == null) return;
                            _openLetterPreview(c, profile);
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplaintTile extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const _ComplaintTile({required this.complaint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (complaint.status) {
      ComplaintStatus.draft => AppColors.textTertiary,
      ComplaintStatus.ready => AppColors.warning,
      ComplaintStatus.sent => AppColors.info,
      ComplaintStatus.acknowledged => AppColors.success,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${complaint.band.label} shortfall complaint',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${complaint.averageHoursPerDay.toStringAsFixed(1)}h/day recorded of '
                    '${complaint.promisedHoursPerDay.toStringAsFixed(0)}h promised '
                    '(${complaint.fulfillmentPercentage.toStringAsFixed(0)}%)',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  phone,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the generated complaint letter as plain text, lets the customer pick
/// AEDC or NERC as the recipient, and exports it as a PDF for printing,
/// sharing or emailing.
class _LetterPreviewPage extends StatefulWidget {
  final Complaint complaint;
  final UserProfile profile;
  final ComplaintLetterGenerator generator;

  const _LetterPreviewPage({
    required this.complaint,
    required this.profile,
    required this.generator,
  });

  @override
  State<_LetterPreviewPage> createState() => _LetterPreviewPageState();
}

class _LetterPreviewPageState extends State<_LetterPreviewPage> {
  String _recipient = 'aedc';

  String get _letterText => widget.generator.generate(
        complaint: widget.complaint,
        profile: widget.profile,
        recipient: _recipient,
      );

  Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            _recipient == 'nerc'
                ? 'Complaint to NERC'
                : 'Complaint to AEDC',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(_letterText, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complaint Letter',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _RecipientChip(
                    label: 'AEDC',
                    selected: _recipient == 'aedc',
                    onTap: () => setState(() => _recipient = 'aedc'),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _RecipientChip(
                    label: 'NERC (Regulator)',
                    selected: _recipient == 'nerc',
                    onTap: () => setState(() => _recipient = 'nerc'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  _letterText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _letterText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Letter copied to clipboard')),
                        );
                      },
                      child: const Text('Copy Text'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Printing.layoutPdf(onLayout: (_) => _buildPdf()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Export / Share PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecipientChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
