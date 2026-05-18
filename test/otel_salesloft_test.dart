// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_salesloft/otel_salesloft.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_salesloft-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('cadence_memberships.create records cadence + step + opt-out', () async {
    await tracedSalesloft<String>(
      operation: 'cadence_memberships.create',
      invoke: () async => const SalesloftCallResult(
        value: 'ok',
        result: SalesloftResult(
          teamId: 't_1',
          personId: 'p_1',
          cadenceId: 'cad_1',
          cadenceMembershipState: 'active',
          cadenceStep: 1,
          totalCadenceSteps: 8,
          optedOut: false,
          mailboxId: 'mb_1',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('salesloft cadence_memberships.create')!,
    );
    expect(a['salesloft.cadence.id'], 'cad_1');
    expect(a['salesloft.cadence_membership.state'], 'active');
    expect(a['salesloft.cadence.step'], 1);
    expect(a['salesloft.cadence.total_steps'], 8);
    expect(a['salesloft.person.opted_out'], false);
  });

  test('calls.create records disposition + sentiment', () async {
    await tracedSalesloft<String>(
      operation: 'calls.create',
      invoke: () async => const SalesloftCallResult(
        value: 'ok',
        result: SalesloftResult(
          callId: 'c_1',
          callDisposition: 'meeting_scheduled',
          callSentiment: 'positive',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('salesloft calls.create')!);
    expect(a['salesloft.call.disposition'], 'meeting_scheduled');
    expect(a['salesloft.call.sentiment'], 'positive');
  });

  test('bounced email sets span error', () async {
    await tracedSalesloft<String>(
      operation: 'emails.send',
      invoke: () async => const SalesloftCallResult(
        value: 'ok',
        result: SalesloftResult(
          emailId: 'e_1',
          emailStatus: 'bounced',
        ),
      ),
    );
    expect(
      spans.findSpanByName('salesloft emails.send')!.status,
      SpanStatusCode.Error,
    );
  });

  test('replied membership does NOT set span error', () async {
    await tracedSalesloft<String>(
      operation: 'cadence_memberships.create',
      invoke: () async => const SalesloftCallResult(
        value: 'ok',
        result: SalesloftResult(
          cadenceMembershipState: 'replied',
        ),
      ),
    );
    expect(
      spans.findSpanByName('salesloft cadence_memberships.create')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutSalesloftInstrumentationAsync(() async {
      await tracedSalesloft<String>(
        operation: 'people.create',
        invoke: () async => const SalesloftCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('salesloft '), isEmpty);
  });
}
