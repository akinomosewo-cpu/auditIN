import 'package:flutter_test/flutter_test.dart';
import 'package:band_a_audit/core/constants/app_constants.dart';
import 'package:band_a_audit/domain/entities/power_log.dart';
import 'package:band_a_audit/domain/usecases/power_usecases.dart';

void main() {
  group('DailyStat band-hour calculations', () {
    test('meetsPromise is true when hoursOn reaches the promised hours', () {
      final stat = DailyStat(
        date: DateTime(2026, 1, 1),
        hoursOn: 20,
        hoursOff: 4,
        outageCount: 1,
        longestOutage: 4,
        longestUptime: 12,
        band: ElectricityBand.a,
        meetsPromise: true,
      );

      expect(stat.promisedHours, 20);
      expect(stat.deficitHours, 0);
      expect(stat.supplyPercentage, closeTo(83.33, 0.01));
    });

    test('deficitHours reports the shortfall for an under-served Band A day', () {
      const band = ElectricityBand.a;
      final stat = DailyStat(
        date: DateTime(2026, 1, 2),
        hoursOn: 11,
        hoursOff: 13,
        outageCount: 3,
        longestOutage: 6,
        longestUptime: 5,
        band: band,
        meetsPromise: false,
      );

      expect(stat.deficitHours, 9); // 20 promised - 11 actual
      expect(stat.meetsPromise, isFalse);
    });

    test('deficitHours never goes negative when supply exceeds the promise', () {
      final stat = DailyStat(
        date: DateTime(2026, 1, 3),
        hoursOn: 24,
        hoursOff: 0,
        outageCount: 0,
        longestOutage: 0,
        longestUptime: 24,
        band: ElectricityBand.a,
        meetsPromise: true,
      );

      expect(stat.deficitHours, 0);
    });

    test('extraChargeEstimate is 0 for a Band B customer (same rate)', () {
      final stat = DailyStat(
        date: DateTime(2026, 1, 4),
        hoursOn: 16,
        hoursOff: 8,
        outageCount: 1,
        longestOutage: 8,
        longestUptime: 16,
        band: ElectricityBand.b,
        meetsPromise: true,
      );

      expect(stat.extraChargeEstimate, 0);
    });

    test('extraChargeEstimate is positive for a Band A customer', () {
      final stat = DailyStat(
        date: DateTime(2026, 1, 5),
        hoursOn: 10,
        hoursOff: 14,
        outageCount: 2,
        longestOutage: 8,
        longestUptime: 6,
        band: ElectricityBand.a,
        meetsPromise: false,
      );

      expect(stat.extraChargeEstimate, greaterThan(0));
    });
  });

  group('ElectricityBand', () {
    test('Band A promises 20 hours at NGN 209.50/unit', () {
      expect(ElectricityBand.a.promisedHours, 20);
      expect(ElectricityBand.a.ratePerUnit, 209.50);
    });

    test('Band B promises 16 hours at NGN 62.48/unit', () {
      expect(ElectricityBand.b.promisedHours, 16);
      expect(ElectricityBand.b.ratePerUnit, 62.48);
    });
  });

  group('Complaint threshold logic', () {
    test('a Band A customer averaging below 60% of promised hours is flagged', () {
      final summary = DashboardSummary(
        averageHoursPerDay: 10,
        totalDeficitHours: 70,
        totalOutages: 12,
        estimatedOvercharge: 5000,
        userProfile: UserProfile(
          id: '1',
          name: 'Test User',
          address: 'Test Address',
          meterNumber: '123',
          accountNumber: '456',
          band: ElectricityBand.a,
          feederName: 'Test Feeder',
          district: 'Wuse',
          latitude: 9.06,
          longitude: 7.48,
          registeredAt: DateTime(2026, 1, 1),
        ),
      );

      // 10 / 20 = 50% < 60% threshold
      expect(summary.isBelowThreshold, isTrue);
      expect(summary.fulfillmentRate, 50);
    });

    test('a Band A customer averaging above the threshold is not flagged', () {
      final summary = DashboardSummary(
        averageHoursPerDay: 18,
        totalDeficitHours: 6,
        totalOutages: 2,
        estimatedOvercharge: 500,
        userProfile: UserProfile(
          id: '1',
          name: 'Test User',
          address: 'Test Address',
          meterNumber: '123',
          accountNumber: '456',
          band: ElectricityBand.a,
          feederName: 'Test Feeder',
          district: 'Wuse',
          latitude: 9.06,
          longitude: 7.48,
          registeredAt: DateTime(2026, 1, 1),
        ),
      );

      // 18 / 20 = 90% >= 60% threshold
      expect(summary.isBelowThreshold, isFalse);
    });

    test('threshold constant matches the documented 60% policy', () {
      expect(AppConstants.complaintThresholdPercent, 0.6);
    });
  });
}
