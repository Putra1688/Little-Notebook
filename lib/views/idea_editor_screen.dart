import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/notebook_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../themes/app_colors.dart';
import '../themes/app_gradients.dart';
import '../themes/app_shadows.dart';

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

class _IdeaEditorScreenState extends State<IdeaEditorScreen> 
    with SingleTickerProviderStateMixin {
  late TextEditingController textController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    final idea = widget.notebook.ideas[widget.ideaIndex];
    textController = TextEditingController(text: idea.text);
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveIdea() {
    final text = textController.text;
    final updatedIdea = Idea(text: text);
    
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);
    final notebooks = notebookNotifier.value;
    
    // Find notebook
    int notebookIndex = -1;
    for (int i = 0; i < notebooks.length; i++) {
      if (notebooks[i].title == widget.notebook.title) {
        notebookIndex = i;
        break;
      }
    }
    
    if (notebookIndex == -1) return;

    final currentNotebook = notebooks[notebookIndex];
    List<Idea> updatedIdeas = List<Idea>.from(currentNotebook.ideas)
      ..[widget.ideaIndex] = updatedIdea;

    final updatedNotebooks = List<Notebook>.from(notebooks)
      ..[notebookIndex] = Notebook(
        title: currentNotebook.title,
        ideas: updatedIdeas,
      );

    notebookNotifier.value = updatedNotebooks;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.neonCyber,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppShadows.neonGlow,
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Neural Idea Editor'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _saveIdea,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassmorphicCard(
            blur: 20,
            borderRadius: 20,
            child: TextField(
              controller: textController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Write your neural idea here...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
