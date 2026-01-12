import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import 'package:url_launcher/url_launcher.dart'; // Keep if used for other things
import '../../../core/network/api_client.dart'; // Added
import '../../../features/academics/domain/models.dart'; // Added Question if needed from exam domain or share


// Simple provider for papers
final examPapersProvider = FutureProvider.autoDispose<List<ExamPaper>>((ref) async {
  final dio = ref.read(apiClientProvider).client;
  final response = await dio.get('/exams/papers/');
  final List results = response.data['results'];
  return results.map((json) => ExamPaper.fromJson(json)).toList();
});

class ExamPaperListScreen extends ConsumerWidget {
  const ExamPaperListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papersAsync = ref.watch(examPapersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generated Exam Papers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/exams/paper_generator'),
        child: const Icon(Icons.add),
      ),
      body: papersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (papers) {
          if (papers.isEmpty) {
            return const Center(child: Text('No exam papers generated yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.indigo),
                  title: Text(paper.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${paper.subjectName ?? 'Unknown Subject'} • ${paper.totalMarks} Marks'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () async {
                          try {
                            final dio = ref.read(apiClientProvider).client;
                            final detailResponse = await dio.get('/exams/papers/${paper.id}/');
                            final detailJson = detailResponse.data;
                            final List qs = detailJson['questions'];
                            final List<Question> questions = qs.map((q) => Question.fromJson(q['question'])).toList();
                            await ref.read(examRepositoryProvider).exportExamPaperPdf(paper, questions);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                             title: const Text('Delete Paper?'),
                             actions: [
                               TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Cancel')),
                               TextButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Delete')),
                             ]
                           ));
                           if (confirm == true) {
                             await ref.read(examRepositoryProvider).deleteExamPaper(paper.id);
                             ref.refresh(examPapersProvider);
                           }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
