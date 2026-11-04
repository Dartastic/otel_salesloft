// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_salesloft/otel_salesloft.dart';

/// Traces SalesLoft calls with OpenTelemetry.
///
/// `otel_salesloft` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each SalesLoft call in
/// [tracedSalesloft]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'salesloft-example');

  // Wraps a SalesLoft API call in a CLIENT span.
  final salesloftId = await tracedSalesloft<String>(
    operation: 'people.create',
    invoke: () async {
      // Make the SalesLoft call here, then report what it returned.
      const id = 'salesloft_8f3a2c';
      return const SalesloftCallResult(
          value: id,
          result: SalesloftResult(
              teamId: 'team_8f3a2c',
              entityKind: 'person',
              entityId: 'entity_8f3a2c',
              personId: 'person_8f3a2c',
              accountId: 'account_8f3a2c',
              cadenceId: 'cadence_8f3a2c',
              cadenceMembershipState: 'active',
              cadenceStep: 1,
              totalCadenceSteps: 1,
              emailId: 'email_8f3a2c',
              emailStatus: 'sent',
              callId: 'call_8f3a2c',
              callDisposition: 'connected',
              callSentiment: 'positive',
              taskId: 'task_8f3a2c',
              taskType: 'email',
              mailboxId: 'mailbox_8f3a2c',
              optedOut: true,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedSalesloft people.create returned $salesloftId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSalesloftInstrumentationAsync.
  await runWithoutSalesloftInstrumentationAsync(
    () => tracedSalesloft<String>(
      operation: 'people.create',
      invoke: () async {
        const id = 'salesloft_8f3a2c';
        return const SalesloftCallResult(
            value: id,
            result: SalesloftResult(
                teamId: 'team_8f3a2c',
                entityKind: 'person',
                entityId: 'entity_8f3a2c',
                personId: 'person_8f3a2c',
                accountId: 'account_8f3a2c',
                cadenceId: 'cadence_8f3a2c',
                cadenceMembershipState: 'active',
                cadenceStep: 1,
                totalCadenceSteps: 1,
                emailId: 'email_8f3a2c',
                emailStatus: 'sent',
                callId: 'call_8f3a2c',
                callDisposition: 'connected',
                callSentiment: 'positive',
                taskId: 'task_8f3a2c',
                taskType: 'email',
                mailboxId: 'mailbox_8f3a2c',
                optedOut: true,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
