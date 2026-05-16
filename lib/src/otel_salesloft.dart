// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_salesloft_suppression.dart';

const _tracerName = 'dartastic_otel_libs_salesloft';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class SalesloftResult {
  const SalesloftResult({
    this.teamId,
    this.entityKind,
    this.entityId,
    this.personId,
    this.accountId,
    this.cadenceId,
    this.cadenceMembershipState,
    this.cadenceStep,
    this.totalCadenceSteps,
    this.emailId,
    this.emailStatus,
    this.callId,
    this.callDisposition,
    this.callSentiment,
    this.taskId,
    this.taskType,
    this.mailboxId,
    this.optedOut,
    this.statusCode,
  });

  /// SalesLoft team (multi-tenant scope).
  final String? teamId;

  /// `person` / `account` / `cadence` / `cadence_membership` /
  /// `email` / `call` / `task` / `crm_activity` / `user` /
  /// `email_template` / `step` / `meeting` / `import`.
  final String? entityKind;

  final String? entityId;

  final String? personId;
  final String? accountId;

  final String? cadenceId;

  /// `active` / `paused` / `completed` / `unsubscribed` / `bounced` /
  /// `replied` / `removed` / `failed`.
  final String? cadenceMembershipState;

  /// Current step within the cadence (1-based).
  final int? cadenceStep;

  final int? totalCadenceSteps;

  final String? emailId;

  /// `sent` / `pending` / `delivered` / `bounced` / `opened` /
  /// `clicked` / `replied` / `error` / `archived`.
  final String? emailStatus;

  final String? callId;

  /// `connected` / `not_connected` / `no_answer` / `voicemail` /
  /// `bad_number` / `gatekeeper` / `meeting_scheduled` /
  /// `not_interested`.
  final String? callDisposition;

  /// `positive` / `neutral` / `negative` (when SalesLoft Conversational
  /// Intelligence is enabled).
  final String? callSentiment;

  final String? taskId;

  /// `email` / `call` / `other` / `linkedin` / `general`.
  final String? taskType;

  /// Mailbox the send went through (rate limits + signature scope).
  final String? mailboxId;

  /// `true` when the person has opted-out of all further outreach.
  final bool? optedOut;

  final int? statusCode;
}

class SalesloftCallResult<T> {
  const SalesloftCallResult({required this.value, this.result});
  final T value;
  final SalesloftResult? result;
}

/// Wraps a SalesLoft API call in a CLIENT span. [operation] is one of
/// `people.create`, `people.update`, `accounts.create`,
/// `cadences.list`, `cadence_memberships.create`,
/// `cadence_memberships.pause`, `emails.send`, `emails.list`,
/// `calls.create`, `tasks.create`, `crm_activities.create`,
/// `meetings.create`, `mailboxes.list`, `email_templates.create`.
Future<T> tracedSalesloft<T>({
  required String operation,
  required Future<SalesloftCallResult<T>> Function() invoke,
}) async {
  if (salesloftInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'salesloft',
    'rpc.method': operation,
    'salesloft.operation': operation,
  };

  final span = _tracer().startSpan(
    'salesloft $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.teamId != null) {
        extras.add(OTel.attributeString(
          'salesloft.team.id',
          r.result!.teamId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'salesloft.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'salesloft.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.personId != null) {
        extras.add(OTel.attributeString(
          'salesloft.person.id',
          r.result!.personId!,
        ));
      }
      if (r.result!.accountId != null) {
        extras.add(OTel.attributeString(
          'salesloft.account.id',
          r.result!.accountId!,
        ));
      }
      if (r.result!.cadenceId != null) {
        extras.add(OTel.attributeString(
          'salesloft.cadence.id',
          r.result!.cadenceId!,
        ));
      }
      if (r.result!.cadenceMembershipState != null) {
        extras.add(OTel.attributeString(
          'salesloft.cadence_membership.state',
          r.result!.cadenceMembershipState!,
        ));
        if (r.result!.cadenceMembershipState == 'failed') {
          span.setStatus(
            SpanStatusCode.Error,
            'SalesLoft cadence_membership failed',
          );
        }
      }
      if (r.result!.cadenceStep != null) {
        extras.add(OTel.attributeInt(
          'salesloft.cadence.step',
          r.result!.cadenceStep!,
        ));
      }
      if (r.result!.totalCadenceSteps != null) {
        extras.add(OTel.attributeInt(
          'salesloft.cadence.total_steps',
          r.result!.totalCadenceSteps!,
        ));
      }
      if (r.result!.emailId != null) {
        extras.add(OTel.attributeString(
          'salesloft.email.id',
          r.result!.emailId!,
        ));
      }
      if (r.result!.emailStatus != null) {
        extras.add(OTel.attributeString(
          'salesloft.email.status',
          r.result!.emailStatus!,
        ));
        if (r.result!.emailStatus == 'error' ||
            r.result!.emailStatus == 'bounced') {
          span.setStatus(
            SpanStatusCode.Error,
            'SalesLoft email ${r.result!.emailStatus}',
          );
        }
      }
      if (r.result!.callId != null) {
        extras.add(OTel.attributeString(
          'salesloft.call.id',
          r.result!.callId!,
        ));
      }
      if (r.result!.callDisposition != null) {
        extras.add(OTel.attributeString(
          'salesloft.call.disposition',
          r.result!.callDisposition!,
        ));
      }
      if (r.result!.callSentiment != null) {
        extras.add(OTel.attributeString(
          'salesloft.call.sentiment',
          r.result!.callSentiment!,
        ));
      }
      if (r.result!.taskId != null) {
        extras.add(OTel.attributeString(
          'salesloft.task.id',
          r.result!.taskId!,
        ));
      }
      if (r.result!.taskType != null) {
        extras.add(OTel.attributeString(
          'salesloft.task.type',
          r.result!.taskType!,
        ));
      }
      if (r.result!.mailboxId != null) {
        extras.add(OTel.attributeString(
          'salesloft.mailbox.id',
          r.result!.mailboxId!,
        ));
      }
      if (r.result!.optedOut != null) {
        extras.add(OTel.attributeBool(
          'salesloft.person.opted_out',
          r.result!.optedOut!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'SalesLoft HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
