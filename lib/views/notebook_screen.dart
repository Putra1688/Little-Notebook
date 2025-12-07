import '../models/data_layer.dart';
import 'package:flutter/material.dart';
import '../provider/notebook_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'idea_editor_screen.dart';

class NotebookScreen extends StatefulWidget {
  final Notebook notebook;
  const NotebookScreen({super.key, required this.notebook});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(
      context,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface.withOpacity(0.9),
                colorScheme.surface.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.secondaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<List<Notebook>>(
            valueListenable: notebookNotifier,
            builder: (context, notebooks, child) {
              final notebookIndex = _findNotebookIndex(
                notebooks,
                widget.notebook.title,
              );
              if (notebookIndex == -1) {
                return const Center(child: Text('Notebook not found'));
              }

              Notebook currentNotebook = notebooks[notebookIndex];

              return Column(
                children: [
                  // Header Info
                  _buildHeaderInfo(currentNotebook),
                  
                  // Ideas List
                  Expanded(child: _buildIdeaGrid(currentNotebook, notebookIndex)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewIdea(context),
        label: const Text('New Idea'),
        icon: const Icon(Icons.add),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildHeaderInfo(Notebook notebook) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${notebook.ideaCount} ideas collected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _findNotebookIndex(List<Notebook> notebooks, String title) {
    for (int i = 0; i < notebooks.length; i++) {
      if (notebooks[i].title == title) {
        return i;
      }
    }
    return -1;
  }

  void _createNewIdea(BuildContext context) {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(
      context,
    );
    final notebooks = notebookNotifier.value;

    final notebookIndex = _findNotebookIndex(notebooks, widget.notebook.title);
    if (notebookIndex == -1) return;

    Notebook currentNotebook = notebooks[notebookIndex];

    // Buat ide baru dengan konten kosong
    Idea newIdea = Idea(text: '');

    List<Idea> updatedIdeas = List<Idea>.from(currentNotebook.ideas)
      ..add(newIdea);
      
    // Create updated notebook object
    Notebook updatedNotebook = Notebook(
      title: currentNotebook.title,
      ideas: updatedIdeas,
    );

    // Update via Service to trigger AutoSave
    NotebookService.updateNotebook(notebookNotifier, notebookIndex, updatedNotebook);

    // Langsung buka editor untuk ide baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IdeaEditorScreen(
            notebook: updatedNotebook,
            ideaIndex: updatedIdeas.length - 1,
          ),
        ),
      );
    });
  }

  Widget _buildIdeaGrid(Notebook notebook, int notebookIndex) {
    if (notebook.ideas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Ideas Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to capture\nyour first brilliant idea.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: notebook.ideas.length,
      itemBuilder: (context, index) =>
          _buildIdeaCard(notebook, notebookIndex, index, context),
    );
  }

  Widget _buildIdeaCard(
    Notebook notebook,
    int notebookIndex,
    int ideaIndex,
    BuildContext context,
  ) {
    final idea = notebook.ideas[ideaIndex];
    final colorScheme = Theme.of(context).colorScheme;

    // Format tanggal
    String formattedDate = _formatDate(idea.createdAt);

    // Buat preview dari konten
    String previewText = _getPreviewText(idea.text);
    bool isEmpty = previewText.isEmpty;

    return GlassmorphicCard(
      blur: 10,
      borderRadius: 16,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                IdeaEditorScreen(notebook: notebook, ideaIndex: ideaIndex),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withOpacity(0.9),
                  colorScheme.surfaceContainerHighest.withOpacity(0.4),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    isEmpty ? 'Empty Note' : previewText,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isEmpty 
                          ? colorScheme.outline.withOpacity(0.5) 
                          : colorScheme.onSurface,
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                _showDeleteConfirmation(context, notebookIndex, ideaIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewText(String content) {
    if (content.isEmpty) return '';
    return content.trim();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int notebookIndex,
    int ideaIndex,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Idea?'),
          content: const Text('This action cannot be undone.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _deleteIdea(context, notebookIndex, ideaIndex);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteIdea(BuildContext context, int notebookIndex, int ideaIndex) {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(
      context,
    );
    final notebooks = notebookNotifier.value;
    final currentNotebook = notebooks[notebookIndex];

    List<Idea> updatedIdeas = List<Idea>.from(currentNotebook.ideas)
      ..removeAt(ideaIndex);
      
    Notebook updatedNotebook = Notebook(
      title: currentNotebook.title,
      ideas: updatedIdeas,
    );

    // Update via Service to trigger AutoSave
    NotebookService.updateNotebook(notebookNotifier, notebookIndex, updatedNotebook);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Idea deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

