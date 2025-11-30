import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/notebook_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/holographic_button.dart';
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
  late TextEditingController _textController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isNewIdea = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.notebook.ideas[widget.ideaIndex].text);
    _isNewIdea = widget.notebook.ideas[widget.ideaIndex].text.isEmpty;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
    
    _textController.addListener(() {
      if (!_hasChanges && _textController.text != widget.notebook.ideas[widget.ideaIndex].text) {
        setState(() {
          _hasChanges = true;
        });
      }
    });

    // Show welcome modal for new ideas
    if (_isNewIdea) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeModal();
      });
    }
  }

  void _showWelcomeModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.of(context).pop();
        });

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fadeAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryNeon.withOpacity(0.9),
                          AppColors.secondaryNeon.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNeon.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'NEURAL ACTIVATION',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Begin your thought process',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveAndBack() {
    _saveChanges();
    Navigator.of(context).pop();
  }

  void _saveChanges() {
    if (!_hasChanges) return;
    
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

    final updatedNotebooks = List<Notebook>.from(notebooks)
      ..[notebookIndex] = Notebook(
        title: widget.notebook.title,
        ideas: updatedIdeas,
      );

    notebookNotifier.value = updatedNotebooks;
    
    // Show save confirmation
    _showSaveConfirmation();
  }

  void _showSaveConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accentNeon.withOpacity(0.9),
        content: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 10),
            Text('Neural Pattern Saved'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idea = widget.notebook.ideas[widget.ideaIndex];
    
    // Create preview for appbar
    String previewText = _getPreviewText(idea.text);
    int wordCount = _textController.text.split(' ').length;
    int charCount = _textController.text.length;

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
            onPressed: _saveAndBack,
          ),
          title: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewText.isNotEmpty ? previewText : 'Neural Thought',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Editing: ${_formatDate(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppGradients.neonCyber,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppShadows.neonGlow,
                  ),
                  child: const Icon(Icons.save, size: 18, color: Colors.white),
                ),
                onPressed: _saveAndBack,
              ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Stats and Info Card
                      GlassmorphicCard(
                        blur: 20,
                        borderRadius: 15,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem('Created', _formatDate(idea.createdAt)),
                              _buildInfoItem('Words', '$wordCount'),
                              _buildInfoItem('Chars', '$charCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Editor
                      Expanded(
                        child: GlassmorphicCard(
                          blur: 15,
                          borderRadius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                height: 1.6,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Begin your neural thought process...\n\nLet your ideas flow without boundaries. This is your space for unlimited creativity and innovation.\n\nThe universe of ideas awaits your exploration...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _fadeAnimation.value,
                child: HolographicButton(
                  onPressed: _saveAndBack,
                  size: 60,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(height: 2),
                      Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textNeon,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  String _getPreviewText(String content) {
    if (content.isEmpty) return '';
    
    // Take first 40 characters, remove newlines
    String cleanText = content.replaceAll('\n', ' ');
    if (cleanText.length > 40) {
      return '${cleanText.substring(0, 40)}...';
    }
    return cleanText;
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}