import '../models/data_layer.dart';
import 'package:flutter/material.dart';
import '../provider/notebook_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/holographic_button.dart';
import '../themes/app_colors.dart';
import '../themes/app_gradients.dart';
import '../themes/app_shadows.dart';
import 'idea_editor_screen.dart';

class NotebookScreen extends StatefulWidget {
  final Notebook notebook;
  const NotebookScreen({super.key, required this.notebook});

  @override
  State createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Notebook>> NotebooksNotifier = NotebookProvider.of(context);

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
          title: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Text(
                  widget.notebook.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
        ),
        body: ValueListenableBuilder<List<Notebook>>(
          valueListenable: NotebooksNotifier,
          builder: (context, notebooks, child) {
            final matchingNotebooks = notebooks.where((p) => p.title == widget.notebook.title).toList();
            if (matchingNotebooks.isEmpty) {
              return _buildEmptyState('Dimension not found');
            }
            
            Notebook currentNotebook = matchingNotebooks.first;

            return Column(
              children: [
                // Header Stats
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GlassmorphicCard(
                          blur: 20,
                          borderRadius: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.lightbulb_outline,
                                '${currentNotebook.ideaCount}',
                                'Neural Ideas',
                              ),
                              _buildStatItem(
                                Icons.auto_awesome,
                                '${currentNotebook.ideas.where((i) => i.text.length > 50).length}',
                                'Deep Thoughts',
                              ),
                              _buildStatItem(
                                Icons.timeline,
                                '${_calculateTotalWords(currentNotebook)}',
                                'Words',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(child: _buildIdeaList(currentNotebook))
              ],
            );
          },
        ),
        floatingActionButton: _buildAddIdeaButton(context),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.neonCyber,
            shape: BoxShape.circle,
            boxShadow: AppShadows.neonGlow,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textNeon,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  int _calculateTotalWords(Notebook notebook) {
    return notebook.ideas.fold(0, (total, idea) {
      return total + idea.text.split(' ').length;
    });
  }

  Widget _buildAddIdeaButton(BuildContext context) {
    return HolographicButton(
      onPressed: () => _createNewIdea(context),
      size: 60,
      child: const Icon(Icons.add, size: 30),
    );
  }

  void _createNewIdea(BuildContext context) {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);
    final notebooks = notebookNotifier.value;
    
    final notebookIndex = _findNotebookIndex(notebooks, widget.notebook.title);
    if (notebookIndex == -1) return;

    Notebook currentNotebook = notebooks[notebookIndex];

    // Buat ide baru dengan konten kosong
    Idea newIdea = Idea(text: '');

    List<Idea> updatedIdeas = List<Idea>.from(currentNotebook.ideas)..add(newIdea);

    // Update notebook dengan ide baru
    final updatedNotebooks = List<Notebook>.from(notebooks)
      ..[notebookIndex] = Notebook(
        title: currentNotebook.title,
        ideas: updatedIdeas,
      );

    notebookNotifier.value = updatedNotebooks;

    // Langsung buka editor untuk ide baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => IdeaEditorScreen(
            notebook: updatedNotebooks[notebookIndex],
            ideaIndex: updatedIdeas.length - 1,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  int _findNotebookIndex(List<Notebook> notebooks, String title) {
    for (int i = 0; i < notebooks.length; i++) {
      if (notebooks[i].title == title) {
        return i;
      }
    }
    return -1;
  }

  Widget _buildIdeaList(Notebook notebook) {
    if (notebook.ideas.isEmpty) {
      return _buildEmptyState('No Neural Ideas Yet');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: notebook.ideas.length,
        itemBuilder: (context, index) => _buildIdeaTile(notebook, index, context),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: GlassmorphicCard(
        blur: 15,
        borderRadius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the + button to create your first neural idea',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaTile(Notebook notebook, int ideaIndex, BuildContext context) {
    final idea = notebook.ideas[ideaIndex];
    final notebookIndex = _findNotebookIndex(NotebookProvider.of(context).value, notebook.title);

    // Format tanggal
    String formattedDate = _formatDate(idea.createdAt);
    
    // Buat preview dari konten
    String previewText = _getPreviewText(idea.text);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.5),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: GlassmorphicCard(
              blur: 15,
              borderRadius: 15,
              padding: const EdgeInsets.all(0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => IdeaEditorScreen(
                          notebook: notebook,
                          ideaIndex: ideaIndex,
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        // Number Badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppGradients.neonCyber,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: AppShadows.neonGlow,
                          ),
                          child: Center(
                            child: Text(
                              '${ideaIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                previewText.isNotEmpty ? previewText : 'New Neural Idea',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Delete Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.dangerNeon.withOpacity(0.8),
                                  Colors.red.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete, size: 18, color: Colors.white),
                          ),
                          onPressed: () {
                            _showDeleteConfirmation(context, notebookIndex, ideaIndex);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getPreviewText(String content) {
    if (content.isEmpty) return '';
    
    // Ambil 60 karakter pertama, hilangkan newline
    String cleanText = content.replaceAll('\n', ' ');
    if (cleanText.length > 60) {
      return '${cleanText.substring(0, 60)}...';
    }
    return cleanText;
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

  void _showDeleteConfirmation(BuildContext context, int notebookIndex, int ideaIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassmorphicCard(
            blur: 25,
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.dangerNeon,
                        Colors.red,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dangerNeon.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.warning, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Neural Idea?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This action cannot be undone',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: HolographicButton(
                        onPressed: () {
                          _deleteIdea(context, notebookIndex, ideaIndex);
                          Navigator.of(context).pop();
                        },
                        gradient: LinearGradient(
                          colors: [
                            AppColors.dangerNeon,
                            Colors.red,
                          ],
                        ),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteIdea(BuildContext context, int notebookIndex, int ideaIndex) {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);
    final notebooks = notebookNotifier.value;
    final currentNotebook = notebooks[notebookIndex];

    List<Idea> updatedIdeas = List<Idea>.from(currentNotebook.ideas)..removeAt(ideaIndex);

    final updatedNotebooks = List<Notebook>.from(notebooks)
      ..[notebookIndex] = Notebook(
        title: currentNotebook.title,
        ideas: updatedIdeas,
      );

    notebookNotifier.value = updatedNotebooks;
    
    // Show deletion effect
    _showDeletionEffect();
  }

  void _showDeletionEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dangerNeon.withOpacity(0.9),
        content: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 10),
            Text('Neural Idea Deleted'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}