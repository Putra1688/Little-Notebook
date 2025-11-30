import '../models/notebook.dart';

class NotebookStorage {
  final List<Notebook> _notebooks = [];

  List<Notebook> getAll() {
    return _notebooks;
  }

  void add(Notebook notebook) {
    _notebooks.add(notebook);
  }

  void remove(int index) {
    _notebooks.removeAt(index);
  }

  void update(int index, Notebook notebook) {
    _notebooks[index] = notebook;
  }
}
