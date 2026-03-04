import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

class KierownikPage extends StatefulWidget {
  const KierownikPage({super.key});

  @override
  State<KierownikPage> createState() => _KierownikPageState();
}

class _KierownikPageState extends State<KierownikPage> {
  late final List<_LeaveRequest> _requests = [
    _LeaveRequest(
      id: 1,
      employeeName: 'Anna Nowak',
      dateRange: '10.03.2026 - 14.03.2026',
      days: 5,
      status: _LeaveRequestStatus.pending,
    ),
    _LeaveRequest(
      id: 2,
      employeeName: 'Marek Kowalski',
      dateRange: '18.03.2026 - 19.03.2026',
      days: 2,
      status: _LeaveRequestStatus.pending,
    ),
    _LeaveRequest(
      id: 3,
      employeeName: 'Ewa Wiśniewska',
      dateRange: '01.04.2026 - 03.04.2026',
      days: 3,
      status: _LeaveRequestStatus.approved,
    ),
    _LeaveRequest(
      id: 4,
      employeeName: 'Piotr Zieliński',
      dateRange: '22.04.2026 - 25.04.2026',
      days: 4,
      status: _LeaveRequestStatus.approved,
    ),
  ];

  void _approveRequest(int id) {
    setState(() {
      final index = _requests.indexWhere((request) => request.id == id);
      if (index == -1) {
        return;
      }
      _requests[index] = _requests[index].copyWith(
        status: _LeaveRequestStatus.approved,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wniosek urlopowy został zaakceptowany.')),
    );
  }

  Future<void> _confirmCancelRequest(int id) async {
    final confirmed = await _showConfirmDialog(
      title: 'Anulować wniosek?',
      content: 'Czy na pewno chcesz anulować ten wniosek urlopowy?',
      confirmLabel: 'Anuluj wniosek',
    );

    if (confirmed == true) {
      _cancelRequest(id);
    }
  }

  Future<void> _confirmUndoCanceledRequest(int id) async {
    final confirmed = await _showConfirmDialog(
      title: 'Cofnąć anulowanie?',
      content: 'Czy na pewno chcesz cofnąć anulowanie tego wniosku?',
      confirmLabel: 'Cofnij anulowanie',
    );

    if (confirmed == true) {
      _undoCanceledRequest(id);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Nie'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  void _cancelRequest(int id) {
    setState(() {
      final index = _requests.indexWhere((request) => request.id == id);
      if (index == -1) {
        return;
      }
      _requests[index] = _requests[index].copyWith(
        status: _LeaveRequestStatus.canceled,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wniosek urlopowy został anulowany.')),
    );
  }

  void _undoCanceledRequest(int id) {
    setState(() {
      final index = _requests.indexWhere((request) => request.id == id);
      if (index == -1) {
        return;
      }
      _requests[index] = _requests[index].copyWith(
        status: _LeaveRequestStatus.pending,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anulowanie cofnięte. Wniosek wrócił do akceptacji.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _requests
        .where((request) => request.status == _LeaveRequestStatus.pending)
        .toList();
    final approved = _requests
        .where((request) => request.status == _LeaveRequestStatus.approved)
        .toList();
    final canceled = _requests
        .where((request) => request.status == _LeaveRequestStatus.canceled)
        .toList();

    return Scaffold(
      appBar: buildAppBar(context, 'Kierownik'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(
            'Wnioski urlopowe do akceptacji (${pending.length})',
          ),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            const _EmptySection(message: 'Brak wniosków do akceptacji')
          else
            ...pending.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RequestCard(
                  request: request,
                  primaryActionLabel: 'Akceptuj',
                  onPrimaryPressed: () => _approveRequest(request.id),
                  secondaryActionLabel: 'Anuluj',
                  onSecondaryPressed: () => _confirmCancelRequest(request.id),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            'Wnioski urlopowe zaakceptowane (${approved.length})',
          ),
          const SizedBox(height: 10),
          if (approved.isEmpty)
            const _EmptySection(message: 'Brak zaakceptowanych wniosków')
          else
            ...approved.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RequestCard(
                  request: request,
                  secondaryActionLabel: 'Anuluj',
                  onSecondaryPressed: () => _confirmCancelRequest(request.id),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildSectionTitle('Wnioski urlopowe anulowane (${canceled.length})'),
          const SizedBox(height: 10),
          if (canceled.isEmpty)
            const _EmptySection(message: 'Brak anulowanych wniosków')
          else
            ...canceled.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RequestCard(
                  request: request,
                  primaryActionLabel: 'Cofnij anulowanie',
                  onPrimaryPressed: () =>
                      _confirmUndoCanceledRequest(request.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _LeaveRequest request;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryPressed;

  const _RequestCard({
    required this.request,
    this.primaryActionLabel,
    this.onPrimaryPressed,
    this.secondaryActionLabel,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (request.status) {
      _LeaveRequestStatus.pending => 'Do akceptacji',
      _LeaveRequestStatus.approved => 'Zaakceptowany',
      _LeaveRequestStatus.canceled => 'Anulowany',
    };

    final statusBackground = switch (request.status) {
      _LeaveRequestStatus.pending => Colors.orange.shade100,
      _LeaveRequestStatus.approved => Colors.green.shade100,
      _LeaveRequestStatus.canceled => Colors.red.shade100,
    };

    final statusColor = switch (request.status) {
      _LeaveRequestStatus.pending => Colors.orange.shade900,
      _LeaveRequestStatus.approved => Colors.green.shade900,
      _LeaveRequestStatus.canceled => Colors.red.shade900,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.employeeName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text('Termin: ${request.dateRange}'),
            Text('Liczba dni: ${request.days}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: statusBackground,
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (onSecondaryPressed != null && secondaryActionLabel != null)
                  TextButton(
                    onPressed: onSecondaryPressed,
                    child: Text(secondaryActionLabel!),
                  ),
                if (onPrimaryPressed != null && primaryActionLabel != null)
                  ElevatedButton(
                    onPressed: onPrimaryPressed,
                    child: Text(primaryActionLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(message, style: TextStyle(color: Colors.grey.shade700)),
      ),
    );
  }
}

class _LeaveRequest {
  final int id;
  final String employeeName;
  final String dateRange;
  final int days;
  final _LeaveRequestStatus status;

  const _LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.dateRange,
    required this.days,
    required this.status,
  });

  _LeaveRequest copyWith({
    int? id,
    String? employeeName,
    String? dateRange,
    int? days,
    _LeaveRequestStatus? status,
  }) {
    return _LeaveRequest(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      dateRange: dateRange ?? this.dateRange,
      days: days ?? this.days,
      status: status ?? this.status,
    );
  }
}

enum _LeaveRequestStatus { pending, approved, canceled }
