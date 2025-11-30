import './idea.dart';

class Notebook {
  final String title;
  final String content;
  final List<Idea> ideas;

  const Notebook({this.title = '', this.ideas = const [], this.content = ''});

  int get ideaCount => ideas.length;

  String get summaryMessage => '$ideaCount ideas collected';
}
