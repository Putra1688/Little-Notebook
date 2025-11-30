import 'package:flutter/material.dart';
import '../models/notebook.dart';

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
  static void addNotebook(
    ValueNotifier<List<Notebook>> notifier,
    Notebook notebook,
  ) {
    notifier.value = [...notifier.value, notebook];
  }

  static void deleteNotebook(
    ValueNotifier<List<Notebook>> notifier,
    int index,
  ) {
    final newList = [...notifier.value];
    newList.removeAt(index);
    notifier.value = newList;
  }

  static void updateNotebook(
    ValueNotifier<List<Notebook>> notifier,
    int index,
    Notebook updated,
  ) {
    final newList = [...notifier.value];
    newList[index] = updated;
    notifier.value = newList;
  }
}
