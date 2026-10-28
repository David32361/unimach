import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/academic_catalog.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/presentation/widgets/interest_picker.dart';
import 'package:unimatch_user/presentation/widgets/searchable_academic_field.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final Set<String> _interests;
  late final Set<String> _animeGenres;
  late final String _initialUniversity;
  late final String _initialCareer;
  AcademicOption? _university;
  AcademicOption? _career;
  late int _avatarId;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider).value!;
    _avatarId = profile.avatarId;
    _initialUniversity = profile.university;
    _initialCareer = profile.career;
    _university = findAcademicOption(hidalgoUniversities, profile.university);
    _career = findAcademicOption(careerCatalog, profile.career);
    _descriptionController = TextEditingController(text: profile.description);
    _interests = profile.interests.toSet();
    _animeGenres = profile.animeGenres.toSet();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final interestError = validateInterestSelection(_interests, _animeGenres);
    if (interestError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(interestError)));
      return;
    }
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          avatarId: _avatarId,
          university: _university!.name,
          career: _career!.name,
          description: _descriptionController.text,
          interests: _interests.toList()..sort(),
          animeGenres: _animeGenres.toList()..sort(),
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
              SearchableAcademicField(
                label: 'Universidad',
                icon: Icons.school_outlined,
                options: hidalgoUniversities,
                initialValue: _initialUniversity,
                enabled: !operation.isLoading,
                onSelected: (option) => _university = option,
              ),
              const SizedBox(height: 14),
              SearchableAcademicField(
                label: 'Carrera',
                icon: Icons.menu_book_outlined,
                options: careerCatalog,
                initialValue: _initialCareer,
                enabled: !operation.isLoading,
                onSelected: (option) => _career = option,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLength: 300,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción personal',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              InterestPicker(
                interests: _interests,
                animeGenres: _animeGenres,
                enabled: !operation.isLoading,
                onInterestChanged: (change) {
                  final (id, selected) = change;
                  setState(() {
                    if (selected) {
                      _interests.add(id);
                    } else {
                      _interests.remove(id);
                      if (id == 'anime') _animeGenres.clear();
                    }
                  });
                },
                onAnimeGenreChanged: (change) {
                  final (id, selected) = change;
                  setState(() {
                    if (selected) {
                      _animeGenres.add(id);
                    } else {
                      _animeGenres.remove(id);
                    }
                  });
                },
              ),
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
