import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/subjects.dart';
import '../../core/utils/date_utils.dart';
import '../../localization/app_localizations.dart';
import '../../models/study_record.dart';
import '../../providers/study_provider.dart';
import '../../utils/validators.dart';

class AddStudyScreen extends StatefulWidget {
  final StudyRecord? existing;

  const AddStudyScreen({super.key, this.existing});

  @override
  State<AddStudyScreen> createState() => _AddStudyScreenState();
}

class _AddStudyScreenState extends State<AddStudyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicController;
  late final TextEditingController _notesController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  late String _subject;
  late DateTime _date;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _topicController =
        TextEditingController(text: existing?.topic ?? '');
    _notesController =
        TextEditingController(text: existing?.notes ?? '');
    final minutes = existing?.durationMinutes ?? 60;
    _hoursController =
        TextEditingController(text: '${minutes ~/ 60}');
    _minutesController =
        TextEditingController(text: '${minutes % 60}');
    _subject = existing?.subject ?? Subjects.all.first;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editStudy : l10n.addStudy),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FieldLabel(l10n.subject),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: Subjects.all
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text('${Subjects.icons[s] ?? ''}  $s'),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _subject = value);
                      }
                    },
            ),
            const SizedBox(height: 16),
            _FieldLabel(l10n.topic),
            TextFormField(
              controller: _topicController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.enterTopic,
                prefixIcon: const Icon(Icons.topic_outlined),
              ),
              validator: (v) =>
                  Validators.required(v, fieldName: l10n.topic),
            ),
            const SizedBox(height: 16),
            _FieldLabel(l10n.date),
            InkWell(
              onTap: _saving ? null : _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(AppDateUtils.formatFull(_date)),
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel(l10n.duration),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.hours,
                      prefixIcon: const Icon(Icons.schedule),
                    ),
                    validator: (_) => Validators.duration(
                      _hoursController.text,
                      _minutesController.text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.minutes,
                    ),
                    validator: (_) => Validators.duration(
                      _hoursController.text,
                      _minutesController.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FieldLabel(l10n.notes),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.optionalNotes,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEdit ? Icons.check : Icons.add),
              label: Text(_isEdit ? l10n.update : l10n.addStudy),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<StudyProvider>();

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final total = hours * 60 + minutes;

    setState(() => _saving = true);

    try {
      if (widget.existing != null) {
        final updated = widget.existing!.copyWith(
          subject: _subject,
          topic: _topicController.text.trim(),
          date: _date,
          durationMinutes: total,
          notes: _notesController.text.trim(),
        );
        await provider.updateRecord(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recordUpdated)),
        );
      } else {
        await provider.addRecord(
          subject: _subject,
          topic: _topicController.text.trim(),
          date: _date,
          durationMinutes: total,
          notes: _notesController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recordAdded)),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}