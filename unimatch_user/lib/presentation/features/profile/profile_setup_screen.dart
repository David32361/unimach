import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/academic_catalog.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/presentation/widgets/searchable_academic_field.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _gender;
  AcademicOption? _university;
  AcademicOption? _career;
  int _avatarId = 0;

  static const _genders = [
    'Mujer',
    'Hombre',
    'No binario',
    'Prefiero no decir',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(firebaseAuthProvider).currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(profileControllerProvider.notifier)
        .createProfile(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          gender: _gender!,
          university: _university!.name,
          career: _career!.name,
          description: _descriptionController.text,
          avatarId: _avatarId,
        );
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Escribe $field.';
    return null;
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value ?? '');
    if (age == null) return 'Escribe una edad valida.';
    if (age < 18 || age > 99) return 'La edad debe estar entre 18 y 99.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(profileControllerProvider);
    ref.listen<AsyncValue<void>>(profileControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: operation.isLoading
                ? null
                : ref.read(authControllerProvider.notifier).signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Elige un avatar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: avatarCount,
                      itemBuilder: (context, index) {
                        return Semantics(
                          button: true,
                          selected: _avatarId == index,
                          label: 'Avatar ${index + 1}',
                          child: InkResponse(
                            onTap: operation.isLoading
                                ? null
                                : () => setState(() => _avatarId = index),
                            customBorder: const CircleBorder(),
                            child: AvatarSprite(
                              avatarId: index,
                              size: 96,
                              selected: _avatarId == index,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) => _required(value, 'tu nombre'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: _validateAge,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Genero',
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                      items: _genders
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: operation.isLoading
                          ? null
                          : (value) => setState(() => _gender = value),
                      validator: (value) =>
                          value == null ? 'Selecciona una opcion.' : null,
                    ),
                    const SizedBox(height: 14),
                    SearchableAcademicField(
                      label: 'Universidad',
                      icon: Icons.school_outlined,
                      options: hidalgoUniversities,
                      enabled: !operation.isLoading,
                      onSelected: (option) => _university = option,
                    ),
                    const SizedBox(height: 14),
                    SearchableAcademicField(
                      label: 'Carrera',
                      icon: Icons.menu_book_outlined,
                      options: careerCatalog,
                      enabled: !operation.isLoading,
                      onSelected: (option) => _career = option,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLength: 300,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion personal',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      validator: (value) => _required(value, 'una descripcion'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: operation.isLoading ? null : _submit,
                      icon: operation.isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Guardar perfil'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
