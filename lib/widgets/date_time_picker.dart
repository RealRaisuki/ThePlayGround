import 'package:flutter/material.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime?) onDateSelected;
  final Function(TimeOfDay?) onTimeSelected;
  final VoidCallback onClearSelection;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onClearSelection,
  });

  Future<void> _selectDate(BuildContext context) async {
    try {
      if (!context.mounted) return;
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime(2100),
        selectableDayPredicate: (DateTime day) {
          return true;
        },
      );

      if (picked != null) {
        onDateSelected(picked);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackbar(context, 'Failed to select date: $e');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    try {
      if (!context.mounted) return;
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (picked != null) {
        onTimeSelected(picked);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackbar(context, 'Failed to select time: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    return '$month/$day/$year';
  }

  String _getDateButtonText() {
    if (selectedDate == null) return 'Select Date';
    return _formatDate(selectedDate!);
  }

  String _getTimeButtonText(BuildContext context) {
    if (selectedTime == null) return 'Select Time';
    return selectedTime!.format(context);
  }

  String _getCombinedDateTimeText(BuildContext context) {
    if (selectedDate == null && selectedTime == null) return 'No date/time set';

    final dateText = selectedDate != null
        ? _formatDate(selectedDate!)
        : 'No date';
    final timeText = selectedTime != null
        ? selectedTime!.format(context)
        : 'No time';

    return '$dateText, $timeText';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Date & Time:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (selectedDate != null || selectedTime != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getCombinedDateTimeText(context),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  _getDateButtonText(),
                  style: TextStyle(
                    color: selectedDate == null
                        ? Theme.of(context).hintColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context),
                icon: Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  _getTimeButtonText(context),
                  style: TextStyle(
                    color: selectedTime == null
                        ? Theme.of(context).hintColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (selectedDate != null || selectedTime != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onClearSelection,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Date & Time'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],

        if (selectedDate != null && _isDateInPast(selectedDate!)) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                'Selected date is in the past',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  bool _isDateInPast(DateTime date) {
    final now = DateTime.now();
    final comparisonDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return comparisonDate.isBefore(today);
  }
}

extension DateTimeExtensions on DateTime {
  DateTime withTime(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  DateTime toDateTime([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
