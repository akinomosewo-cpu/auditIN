import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../entities/power_log.dart';

/// Builds the plain-text body of a formal supply-shortfall complaint letter
/// addressed to AEDC (with NERC as the regulatory escalation option).
///
/// Kept as pure Dart (no Flutter / PDF dependencies) so the wording and
/// figures that go into the letter can be unit tested without a widget test
/// harness. The PDF rendering layer (in the presentation layer) simply lays
/// this text out on a page.
class ComplaintLetterGenerator {
  const ComplaintLetterGenerator();

  static final DateFormat _dayFormat = DateFormat('d MMMM yyyy');

  /// Whether the recorded supply for [complaint] justifies sending a formal
  /// complaint at all, i.e. the customer received meaningfully less than the
  /// hours their band was promised.
  bool shouldGenerate(Complaint complaint) {
    if (complaint.promisedHoursPerDay <= 0) return false;
    final fulfilment = complaint.averageHoursPerDay / complaint.promisedHoursPerDay;
    return fulfilment < AppConstants.complaintThresholdPercent;
  }

  /// Produces the full letter body as plain text, ready to be shown on
  /// screen, emailed, or laid out into a PDF.
  String generate({
    required Complaint complaint,
    required UserProfile profile,
    String recipient = 'aedc',
  }) {
    final today = _dayFormat.format(DateTime.now());
    final periodStart = _dayFormat.format(complaint.periodStart);
    final periodEnd = _dayFormat.format(complaint.periodEnd);
    final daysTracked = complaint.periodEnd.difference(complaint.periodStart).inDays;
    final fulfilmentPct = complaint.fulfillmentPercentage.clamp(0, 999).toStringAsFixed(1);
    final deficitHoursPerDay =
        (complaint.promisedHoursPerDay - complaint.averageHoursPerDay).clamp(0, 24);

    final addressee = recipient == 'nerc'
        ? 'The Chief Executive Officer\nNigerian Electricity Regulatory Commission (NERC)\nEmail: ${AppConstants.nercEmail}\nPhone: ${AppConstants.nercPhone}'
        : 'The Managing Director\nAbuja Electricity Distribution Company (AEDC)\nEmail: ${AppConstants.aedcComplaintEmail}\nPhone: ${AppConstants.aedcPhone}';

    final subject = recipient == 'nerc'
        ? 'FORMAL COMPLAINT: Non-Compliance by AEDC with Band A Service Guarantee '
            '(Meter No. ${profile.meterNumber})'
        : 'FORMAL COMPLAINT: Failure to Deliver Promised Band A Supply Hours '
            '(Account No. ${profile.accountNumber})';

    final buffer = StringBuffer()
      ..writeln(today)
      ..writeln()
      ..writeln(addressee)
      ..writeln()
      ..writeln('Dear Sir/Madam,')
      ..writeln()
      ..writeln('RE: $subject')
      ..writeln()
      ..writeln(
        'I am a registered ${complaint.band.label} customer of AEDC and I am writing to '
        'formally report a sustained failure to receive the minimum daily supply hours '
        'promised under the Band A service guarantee, despite being billed at the Band A '
        'tariff of NGN ${complaint.band.ratePerUnit.toStringAsFixed(2)} per unit.',
      )
      ..writeln()
      ..writeln('CUSTOMER DETAILS')
      ..writeln('Name: ${profile.name}')
      ..writeln('Address: ${profile.address}')
      ..writeln('Meter Number: ${profile.meterNumber}')
      ..writeln('Account Number: ${profile.accountNumber}')
      ..writeln('Feeder: ${profile.feederName}, ${profile.district}')
      ..writeln('Electricity Band: ${complaint.band.label}')
      ..writeln()
      ..writeln('SUMMARY OF RECORDED SUPPLY ($periodStart to $periodEnd, $daysTracked days)')
      ..writeln(
        'This data was recorded automatically and continuously by the Band A Audit '
        'mobile application, which logs mains power availability via the device\'s '
        'charging-state sensor, independent of any AEDC or third-party reporting.',
      )
      ..writeln('- Promised supply: ${complaint.promisedHoursPerDay.toStringAsFixed(1)} hours/day')
      ..writeln(
        '- Actual average supply recorded: ${complaint.averageHoursPerDay.toStringAsFixed(1)} hours/day',
      )
      ..writeln('- Service fulfilment: $fulfilmentPct% of the promised supply')
      ..writeln('- Average shortfall: ${deficitHoursPerDay.toStringAsFixed(1)} hours/day')
      ..writeln('- Total outage events recorded: ${complaint.totalOutages}')
      ..writeln(
        '- Cumulative deficit over the period: ${complaint.totalDeficitHours.toStringAsFixed(1)} hours',
      )
      ..writeln(
        '- Estimated overcharge for the period (Band A rate vs. Band B rate for the '
        'same units): approximately NGN ${complaint.estimatedOvercharge.toStringAsFixed(2)}',
      )
      ..writeln()
      ..writeln(
        'Under the Nigerian Electricity Regulatory Commission (NERC) Service-Based Tariff '
        '(SBT) framework, customers billed at the Band A rate are entitled to a minimum of '
        '${complaint.promisedHoursPerDay.toStringAsFixed(0)} hours of electricity supply per day. Where this '
        'commitment is not met, the customer is entitled to a rebate, tariff reclassification '
        'to the appropriate lower band, or a corresponding reduction in billing for the '
        'affected period.',
      )
      ..writeln()
      ..writeln('REQUESTED REMEDY')
      ..writeln(
        '1. A billing adjustment/rebate reflecting the shortfall between promised and '
        'actual supply hours for the period stated above.',
      )
      ..writeln(
        '2. Reclassification of this account to the correct band if AEDC cannot '
        'consistently deliver the Band A minimum of ${complaint.promisedHoursPerDay.toStringAsFixed(0)} '
        'hours/day going forward.',
      )
      ..writeln('3. Written confirmation of the steps AEDC will take to restore reliable supply to this feeder.')
      ..writeln()
      ..writeln(
        'I have retained the full, timestamped supply log underlying this complaint and can '
        'provide it in full on request. If this matter is not resolved satisfactorily within '
        '14 days, I reserve the right to escalate this complaint to the Nigerian Electricity '
        'Regulatory Commission (NERC) Forum Office.',
      )
      ..writeln()
      ..writeln('Yours faithfully,')
      ..writeln(profile.name)
      ..writeln('Meter No.: ${profile.meterNumber}');

    return buffer.toString();
  }
}
