import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _universityController;
  late final TextEditingController _careerController;
  late final TextEditingController _descriptionController;
  late final Set<String> _interests;
  late int _avatarId;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider).value!;
    _avatarId = profile.avatarId;
    _universityController = TextEditingController(text: profile.university);
    _careerController = TextEditingController(text: profile.career);
    _descriptionController = TextEditingController(text: profile.description);
    _interests = profile.interests.toSet();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _careerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_interests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos 3 intereses.')),
      );
      return;
    }
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          avatarId: _avatarId,
          university: _universityController.text,
          career: _careerController.text,
          description: _descriptionController.text,
          interests: _interests.toList()..sort(),
        );
    if (saved && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Avatar',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: avatarCount,
                itemBuilder: (context, index) => InkResponse(
                  onTap: operation.isLoading
                      ? null
                      : () => setState(() => _avatarId = index),
                  customBorder: const CircleBorder(),
                  child: AvatarSprite(
                    avatarId: index,
                    size: 90,
                    selected: _avatarId == index,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _universityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Universidad'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _careerController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Carrera'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLength: 300,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripcion personal',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              for (final category in interestCatalog) ...[
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in category.options)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: _interests.contains(option.id),
                        onSelected: operation.isLoading
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _interests.add(option.id);
                                  } else {
                                    _interests.remove(option.id);
                                  }
                                });
                              },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
              FilledButton.icon(
                onPressed: operation.isLoading ? null : _save,
                icon: operation.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
