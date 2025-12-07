import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/notebook_provider.dart';

class IdeaEditorScreen extends StatefulWidget {
  final Notebook notebook;
  final int ideaIndex;

  const IdeaEditorScreen({
    super.key,
    required this.notebook,
    required this.ideaIndex,
  });

  @override
  State<IdeaEditorScreen> createState() => _IdeaEditorScreenState();
}

class _IdeaEditorScreenState extends State<IdeaEditorScreen> {
  late TextEditingController _textController;
  bool _hasChanges = false;
  late DateTime _lastEdited;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.notebook.ideas[widget.ideaIndex].text);
    _lastEdited = widget.notebook.ideas[widget.ideaIndex].createdAt;
    
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges && _textController.text != widget.notebook.ideas[widget.ideaIndex].text) {
      setState(() {
        _hasChanges = true;
        _lastEdited = DateTime.now();
      });
    }
  }

  Future<void> _saveChanges() async {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);
    final notebooks = notebookNotifier.value;
    
    // Find notebook index
    int notebookIndex = -1;
    for (int i = 0; i < notebooks.length; i++) {
      if (notebooks[i].title == widget.notebook.title) {
        notebookIndex = i;
        break;
      }
    }
    
    if (notebookIndex == -1) return;

    List<Idea> updatedIdeas = List<Idea>.from(notebooks[notebookIndex].ideas)
      ..[widget.ideaIndex] = Idea(text: _textController.text);

    Notebook updatedNotebook = Notebook(
      title: widget.notebook.title,
      ideas: updatedIdeas,
    );

    // Update via Service
    NotebookService.updateNotebook(notebookNotifier, notebookIndex, updatedNotebook);
    
    setState(() {
      _hasChanges = false;
    });

    // Show Success Modal
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
    
    if (mounted) {
      Navigator.of(context).pop(); // Exit editor
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saved Successfully',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your idea has been secured.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Do you want to save your changes before leaving?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Discard implies pop(false) -> manually pop
            child: Text(
              'Discard',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true), // Save
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveChanges();
      return false; // _saveChanges handles the pop
    } else if (shouldSave == false) {
      // User chose Discard
      return true; // Look for pop(false) logic
    }
    
    return false; // User dismissed dialog
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _textController.text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
    final charCount = _textController.text.length;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
           Navigator.of(context).pop(); // Force pop if user discarded
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removed header back button
          title: const Text('Edit Idea'),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Info Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time, 
                        size: 14, 
                        color: colorScheme.onSurfaceVariant
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(_lastEdited),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$wordCount words • $charCount chars',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Editor
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: colorScheme.primary,
                    selectionColor: colorScheme.primary.withOpacity(0.3),
                    selectionHandleColor: colorScheme.primary,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing your amazing idea...',
                    hintStyle: TextStyle(
                      color: colorScheme.outline.withOpacity(0.5),
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(24),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveChanges,
          backgroundColor: _hasChanges ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          foregroundColor: _hasChanges ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          child: const Icon(Icons.save_rounded),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} • ${date.day}/${date.month}/${date.year}';
  }
}
