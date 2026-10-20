import 'package:flutter/material.dart';
import 'package:unimatch_user/models/academic_catalog.dart';

class SearchableAcademicField extends StatefulWidget {
  const SearchableAcademicField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.onSelected,
    this.initialValue,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final List<AcademicOption> options;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<AcademicOption?> onSelected;

  @override
  State<SearchableAcademicField> createState() =>
      _SearchableAcademicFieldState();
}

class _SearchableAcademicFieldState extends State<SearchableAcademicField> {
  AcademicOption? _selected;

  @override
  void initState() {
    super.initState();
    _selected = findAcademicOption(widget.options, widget.initialValue ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Autocomplete<AcademicOption>(
        initialValue: TextEditingValue(text: widget.initialValue ?? ''),
        displayStringForOption: (option) => option.name,
        optionsBuilder: (value) =>
            searchAcademicOptions(widget.options, value.text),
        onSelected: (option) {
          setState(() => _selected = option);
          widget.onSelected(option);
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: widget.enabled,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: Icon(widget.icon),
              suffixIcon: const Icon(Icons.expand_more_rounded),
            ),
            onChanged: (value) {
              if (_selected != null && value != _selected?.name) {
                setState(() => _selected = null);
                widget.onSelected(null);
              }
            },
            validator: (_) => _selected == null
                ? 'Selecciona ${widget.label.toLowerCase()} de la lista.'
                : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          final matches = options.toList(growable: false);
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: constraints.maxWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final option = matches[index];
                      return ListTile(
                        dense: true,
                        title: Text(option.name),
                        trailing: Text(option.initials),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
