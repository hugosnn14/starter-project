import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({super.key});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateArticleBloc, CreateArticleState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == CreateArticleStatus.success ||
              current.status == CreateArticleStatus.failure),
      listener: (context, state) {
        if (state.status == CreateArticleStatus.success) {
          context.read<ArticlesBloc>().add(const LoadArticles());
          Navigator.pop(context);
        }

        if (state.status == CreateArticleStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'No se pudo guardar el articulo.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == CreateArticleStatus.submitting;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Create Article',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _authorController,
                    label: 'Author name',
                    validatorMessage: 'Introduce el autor.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    validatorMessage: 'Introduce el titulo.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    validatorMessage: 'Introduce la descripcion.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contentController,
                    label: 'Content',
                    validatorMessage: 'Introduce el contenido.',
                    maxLines: 8,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _onSubmit,
                      child: Text(
                        isSubmitting ? 'Saving...' : 'Save article',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMessage,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<CreateArticleBloc>().add(
          SubmitCreateArticle(
            authorName: _authorController.text.trim(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
          ),
        );
  }
}
