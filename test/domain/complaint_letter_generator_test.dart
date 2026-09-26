import 'package:flutter_test/flutter_test.dart';
import 'package:band_a_audit/core/constants/app_constants.dart';
import 'package:band_a_audit/domain/entities/power_log.dart';
import 'package:band_a_audit/domain/services/complaint_letter_generator.dart';

void main() {
  const generator = ComplaintLetterGenerator();

  UserProfile buildProfile() => UserProfile(
        id: '1',
        name: 'Chinedu Okafor',
        address: '12 Aminu Kano Crescent, Wuse 2, Abuja',
        meterNumber: '04012345678',
        accountNumber: 'AEDC-998877',
        band: ElectricityBand.a,
        feederName: 'Wuse 2 Feeder',
        district: 'Wuse',
        latitude: 9.0765,
        longitude: 7.4951,
        registeredAt: DateTime(2026, 1, 1),
      );

  Complaint buildComplaint({double averageHoursPerDay = 9.5}) => Complaint(
        id: 'c1',
        createdAt: DateTime(2026, 2, 1),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        averageHoursPerDay: averageHoursPerDay,
        promisedHoursPerDay: 20,
        totalOutages: 40,
        totalDeficitHours: 300,
        estimatedOvercharge: 18500.75,
        band: ElectricityBand.a,
        status: ComplaintStatus.draft,
      );

  group('shouldGenerate', () {
    test('is true when the customer received well under 60% of promised hours', () {
      expect(generator.shouldGenerate(buildComplaint(averageHoursPerDay: 9)), isTrue);
    });

    test('is false when the customer is close to their promised hours', () {
      expect(generator.shouldGenerate(buildComplaint(averageHoursPerDay: 19)), isFalse);
    });
  });

  group('generate', () {
    test('AEDC letter includes customer, meter and supply-shortfall figures', () {
      final letter = generator.generate(
        complaint: buildComplaint(),
        profile: buildProfile(),
        recipient: 'aedc',
      );

      expect(letter, contains('Chinedu Okafor'));
      expect(letter, contains('04012345678'));
      expect(letter, contains('AEDC-998877'));
      expect(letter, contains('Band A'));
      expect(letter, contains('209.50'));
      expect(letter, contains('20.0 hours/day'));
      expect(letter, contains('9.5 hours/day'));
      expect(letter, contains('Abuja Electricity Distribution Company'));
      expect(letter, isNot(contains('NERC.gov')));
    });

    test('NERC letter addresses the regulator instead of AEDC', () {
      final letter = generator.generate(
        complaint: buildComplaint(),
        profile: buildProfile(),
        recipient: 'nerc',
      );

      expect(letter, contains('Nigerian Electricity Regulatory Commission'));
      expect(letter, contains('complaint@nerc.gov.ng'));
    });

    test('fulfilment percentage and overcharge amount are formatted into the body', () {
      final letter = generator.generate(
        complaint: buildComplaint(averageHoursPerDay: 10),
        profile: buildProfile(),
      );

      // 10 / 20 = 50.0%
      expect(letter, contains('50.0%'));
      expect(letter, contains('18500.75'));
    });
  });
}
