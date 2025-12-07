import 'package:flutter/material.dart';
import '../models/notebook.dart';
import '../repository/notebook_repository.dart';

class NotebookProvider extends InheritedWidget {
  final ValueNotifier<List<Notebook>> notifier;

  const NotebookProvider({
    super.key,
    required this.notifier,
    required Widget child,
  }) : super(child: child);

  static ValueNotifier<List<Notebook>> of(BuildContext context) {
    final NotebookProvider? provider = context
        .dependOnInheritedWidgetOfExactType<NotebookProvider>();
    return provider!.notifier;
  }

  @override
  bool updateShouldNotify(covariant NotebookProvider oldWidget) {
    return oldWidget.notifier != notifier;
  }
}

class NotebookService {
  // Add a new notebook
  static void addNotebook(
    ValueNotifier<List<Notebook>> notifier,
    Notebook notebook,
  ) async {
    notifier.value = [...notifier.value, notebook];
    await _autoSave(notifier);
  }

  // Delete a notebook by index
  static void deleteNotebook(
    ValueNotifier<List<Notebook>> notifier,
    int index,
  ) async {
    final newList = [...notifier.value];
    newList.removeAt(index);
    notifier.value = newList;
    await _autoSave(notifier);
  }

  // Update an entire notebook (e.g. title change or ideas update)
  static void updateNotebook(
    ValueNotifier<List<Notebook>> notifier,
    int index,
    Notebook updated,
  ) async {
    final newList = [...notifier.value];
    newList[index] = updated;
    notifier.value = newList;
    await _autoSave(notifier);
  }

  // Auto-save whenever changes occur
  static Future<void> _autoSave(ValueNotifier<List<Notebook>> notifier) async {
    await NotebookRepository.saveNotebooks(notifier.value);
  }

  // Load data on app start
  static Future<void> loadNotebooks(ValueNotifier<List<Notebook>> notifier) async {
    final notebooks = await NotebookRepository.loadNotebooks();
    notifier.value = notebooks;
  }
}