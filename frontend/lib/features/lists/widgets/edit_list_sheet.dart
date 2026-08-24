import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../providers/lists_provider.dart';

class EditListSheet extends ConsumerStatefulWidget {
  const EditListSheet({
    super.key,
    required this.listId,
    required this.currentName,
    this.currentNote,
  });

  final String listId;
  final String currentName;
  final String? currentNote;

  @override
  ConsumerState<EditListSheet> createState() => _EditListSheetState();

  static Future<bool?> show(
    BuildContext context, {
    required String listId,
    required String currentName,
    String? currentNote,
  }) {
    return MsSheet.show<bool>(
      context,
      title: 'Edit list',
      child: EditListSheet(
        listId: listId,
        currentName: currentName,
        currentNote: currentNote,
      ),
    );
  }
}

class _EditListSheetState extends ConsumerState<EditListSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _noteCtrl = TextEditingController(text: widget.currentNote ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(listsProvider.notifier).updateList(
            widget.listId,
            name: name,
            note: _noteCtrl.text.trim(),
          );
      // Also refresh the detail view
      ref.invalidate(listDetailProvider(widget.listId));
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.fg1 : AppColors.lightFg1,
            ),
            decoration: InputDecoration(
              hintText: 'List name',
              hintStyle: AppTypography.body.copyWith(color: AppColors.fg3),
              filled: true,
              fillColor: isDark ? AppColors.ink2 : AppColors.paper0,
              border: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inkLine : AppColors.paperLine,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inkLine : AppColors.paperLine,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: const BorderSide(color: AppColors.signal),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
                vertical: AppSpacing.sp3,
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sp3),
          TextField(
            controller: _noteCtrl,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.fg1 : AppColors.lightFg1,
            ),
            decoration: InputDecoration(
              hintText: 'Description (optional)',
              hintStyle: AppTypography.body.copyWith(color: AppColors.fg3),
              filled: true,
              fillColor: isDark ? AppColors.ink2 : AppColors.paper0,
              border: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inkLine : AppColors.paperLine,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inkLine : AppColors.paperLine,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.controlRR,
                borderSide: const BorderSide(color: AppColors.signal),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
                vertical: AppSpacing.sp3,
              ),
            ),
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sp5),
          MsButton(
            label: 'Save',
            fullWidth: true,
            loading: _saving,
            disabled: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
