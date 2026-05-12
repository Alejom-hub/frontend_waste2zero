import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/receipt_response.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Canal: escaneo completado ─────────────────────────────────────────────
  static const _scanChannel = AndroidNotificationDetails(
    'scan_complete',
    'Escaneo completado',
    channelDescription: 'Avisa cuando el análisis de una factura termina',
    importance: Importance.high,
    priority: Priority.high,
  );

  // ── Canal: alerta de vencimiento ──────────────────────────────────────────
  static const _expiryChannel = AndroidNotificationDetails(
    'expiry_warning',
    'Alertas de vencimiento',
    channelDescription: 'Recordatorios de productos próximos a vencer',
    importance: Importance.high,
    priority: Priority.high,
  );

  // ── Inicializar (llamar una vez en main) ──────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Pedir permiso en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ── Notificación inmediata: escaneo completado ────────────────────────────
  Future<void> notifyScanComplete(int productCount) async {
    if (!_initialized) return;
    await _plugin.show(
      0, // ID fijo — sobreescribe la anterior si existe
      '✅ Factura escaneada',
      'Se encontraron $productCount '
          'producto${productCount == 1 ? '' : 's'}. Toca para ver el detalle.',
      const NotificationDetails(android: _scanChannel),
    );
  }

  // ── Programar alertas de vencimiento para una lista de productos ──────────
  Future<void> scheduleExpiryNotifications(
    List<ProductItem> products,
    DateTime scannedAt,
  ) async {
    if (!_initialized) return;

    final local = tz.local;

    for (final product in products) {
      final daysMax = _extractDurationMax(product.raw);
      if (daysMax == null || daysMax <= 0) continue;

      final expiryDate = scannedAt.add(Duration(days: daysMax));

      // Cuántos días antes avisar (mínimo 1, máximo 3)
      final warnDaysBefore = daysMax >= 7
          ? 3
          : daysMax >= 3
              ? 1
              : 0; // < 3 días: notificar el mismo día al mediodía

      final notifyDate = warnDaysBefore > 0
          ? DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 9, 0)
              .subtract(Duration(days: warnDaysBefore))
          : DateTime(
              scannedAt.year, scannedAt.month, scannedAt.day, 12, 0);

      if (notifyDate.isBefore(DateTime.now())) continue;

      final id = _notificationId(product.name, scannedAt);

      final daysLeftAtNotify = expiryDate.difference(notifyDate).inDays;
      final body = daysLeftAtNotify <= 0
          ? '¡Vence hoy! Consúmelo o congélalo.'
          : 'Vence en $daysLeftAtNotify '
              'día${daysLeftAtNotify == 1 ? '' : 's'} '
              '(${_fmtDate(expiryDate)}). ¡Úsalo pronto!';

      await _plugin.zonedSchedule(
        id,
        '⚠️ ${product.name}',
        body,
        tz.TZDateTime.from(notifyDate, local),
        const NotificationDetails(android: _expiryChannel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ── Reprogramar todos los productos existentes (se llama al login) ─────────
  Future<void> rescheduleAll(
    List<({ProductItem product, DateTime scannedAt})> items,
  ) async {
    if (!_initialized) return;
    // Cancelar todas las notificaciones pendientes antes de reprogramar
    await _plugin.cancelAll();
    for (final item in items) {
      await scheduleExpiryNotifications([item.product], item.scannedAt);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extrae duration_max del primer storage_option del producto.
  static int? _extractDurationMax(Map<String, dynamic> raw) {
    final opts = raw['storage_options'];
    if (opts is! List || opts.isEmpty) return null;
    final first = opts.first;
    if (first is! Map) return null;
    final v = first['duration_max'];
    if (v == null) return null;
    return v is num ? v.toInt() : int.tryParse(v.toString());
  }

  /// ID único por producto + fecha de escaneo (evita colisiones entre facturas).
  static int _notificationId(String name, DateTime scannedAt) =>
      (name + scannedAt.millisecondsSinceEpoch.toString())
          .hashCode
          .abs() %
      100000;

  static String _fmtDate(DateTime dt) {
    const m = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${dt.day} de ${m[dt.month - 1]}';
  }
}
