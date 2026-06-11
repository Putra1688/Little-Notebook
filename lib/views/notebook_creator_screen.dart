import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/notebook_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'notebook_screen.dart';
import '../main.dart'; // Import for ThemeController
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class NotebookCreatorScreen extends StatefulWidget {
  const NotebookCreatorScreen({super.key});

  @override
  State<NotebookCreatorScreen> createState() => _NotebookCreatorScreenState();
}

class _NotebookCreatorScreenState extends State<NotebookCreatorScreen>
    with SingleTickerProviderStateMixin {
  final textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final String _adUnitId = kIsWeb 
      ? '' 
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716');

  @override
  void initState() {
    super.initState();
    _loadAd();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  void _loadAd() {
    if (kIsWeb) return;
    
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeController = ThemeController();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Creative Space',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Created to Save Your Idead',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
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
        centerTitle: true,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: themeController,
            builder: (context, child) {
              return IconButton(
                icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeController.toggleTheme,
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
              colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Creator Section
              _buildCreatorSection(),
              
              const SizedBox(height: 24),
              
              // Notebooks List
              Expanded(
                child: _buildNotebookGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }

  Widget _buildCreatorSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GlassmorphicCard(
                blur: 20,
                borderRadius: 24,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Create New Notebook',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: textController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'What are you thinking about?',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: addNotebook,
                          ),
                        ),
                        onSubmitted: (_) => addNotebook(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotebookGrid() {
    ValueNotifier<List<Notebook>> notebookNotifier = NotebookProvider.of(context);

    return ValueListenableBuilder<List<Notebook>>(
      valueListenable: notebookNotifier,
      builder: (context, notebooks, child) {
        if (notebooks.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: notebooks.length,
          itemBuilder: (context, index) {
            final nb = notebooks[index];
            // Staggered animation effect
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final double start = 0.2 + (index * 0.1).clamp(0.0, 0.5);
                final double end = (start + 0.4).clamp(0.0, 1.0);
                
                final animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                );

                return Transform.scale(
                  scale: animation.value,
                  child: Opacity(
                    opacity: animation.value,
                    child: child,
                  ),
                );
              },
              child: _buildNotebookCard(nb),
            );
          },
        );
      },
    );
  }

  Widget _buildNotebookCard(Notebook notebook) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: GlassmorphicCard(
            blur: 15,
            borderRadius: 20,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotebookScreen(notebook: notebook),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerLow.withOpacity(0.8),
                    colorScheme.surfaceContainer.withOpacity(0.4),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    notebook.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${notebook.ideaCount} ideas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () => _showDeleteNotebookConfirmation(context, notebook),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colorScheme.error.withOpacity(0.7),
              ),
              tooltip: 'Delete Notebook',
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteNotebookConfirmation(BuildContext context, Notebook notebook) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notebook?'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${notebook.title}"?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (notebook.ideas.isNotEmpty) ...[
                const Text('This notebook contains the following ideas:'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: notebook.ideas.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final idea = notebook.ideas[index];
                      final text = idea.text.trim().isNotEmpty
                          ? idea.text.trim()
                          : 'Untitled Idea';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• $text',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'These ideas will be permanently deleted.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else
                const Text('This notebook is empty.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _deleteNotebook(notebook);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotebook(Notebook notebook) {
    final notifier = NotebookProvider.of(context);
    final notebooks = notifier.value;
    final index = notebooks.indexOf(notebook);

    if (index != -1) {
      NotebookService.deleteNotebook(notifier, index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notebook "${notebook.title}" deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notebooks Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start your journey by creating\nyour first notebook above.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addNotebook() {
    final text = textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please give your notebook a name'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final notebook = Notebook(title: text, ideas: []);
    NotebookService.addNotebook(NotebookProvider.of(context), notebook);

    textController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notebook "$text" created!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
