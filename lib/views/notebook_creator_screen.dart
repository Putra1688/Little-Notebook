import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/notebook_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/holographic_button.dart';
import '../themes/app_colors.dart';
import '../themes/app_gradients.dart';
import '../themes/app_shadows.dart';
import 'notebook_screen.dart';

class NotebookCreatorScreen extends StatefulWidget {
  const NotebookCreatorScreen({super.key});

  @override
  State<NotebookCreatorScreen> createState() => _NotebookCreatorScreenState();
}

class _NotebookCreatorScreenState extends State<NotebookCreatorScreen> 
    with SingleTickerProviderStateMixin {
  final textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: AppColors.primaryNeon),
                    SizedBox(width: 12),
                    Text(
                      'NEURAL NOTEBOOK',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Creator Card
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GlassmorphicCard(
                      blur: 25,
                      borderRadius: 25,
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.add_circle, color: AppColors.accentNeon),
                              SizedBox(width: 10),
                              Text(
                                'Create New Dimension',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: textController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter dimension name...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.glassWhite.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            onEditingComplete: addNotebook,
                          ),
                          const SizedBox(height: 15),
                          HolographicButton(
                            onPressed: addNotebook,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'CREATE DIMENSION',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(child: _buildNotebookList()),
          ],
        ),
      ),
    );
  }

  void addNotebook() {
    final text = textController.text;
    if (text.isEmpty) return;

    final notebook = Notebook(title: text, ideas: []);
    NotebookService.addNotebook(NotebookProvider.of(context), notebook);

    textController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    
    // Haptic feedback
    _showCreationEffect();
  }

  void _showCreationEffect() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.of(context).pop();
        });
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentNeon.withOpacity(0.8),
                  AppColors.primaryNeon.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentNeon.withOpacity(0.6),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotebookList() {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);
    List<Notebook> notebooks = notebookNotifier.value;

    if (notebooks.isEmpty) {
      return Center(
        child: GlassmorphicCard(
          blur: 15,
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'No Dimensions Created',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your first dimension to start organizing ideas',
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: notebooks.length,
        itemBuilder: (context, index) {
          final nb = notebooks[index];
          return _buildNotebookCard(nb, index);
        },
      ),
    );
  }

  Widget _buildNotebookCard(Notebook notebook, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = 1.0 + (_floatAnimation.value * 0.002);
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => NotebookScreen(notebook: notebook),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: GlassmorphicCard(
              blur: 20,
              borderRadius: 20,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notebook Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.neonCyber,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppShadows.neonGlow,
                    ),
                    child: Icon(
                      Icons.folder_special,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Notebook Title
                  Text(
                    notebook.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.glassBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${notebook.ideaCount} ideas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryNeon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}