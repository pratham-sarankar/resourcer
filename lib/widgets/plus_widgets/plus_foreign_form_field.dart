import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resourcer/data/abstracts/repository.dart';
import 'package:resourcer/data/utils/extensions/validator_extension.dart';
import 'package:resourcer/resource_manager.dart';

class PlusForeignFormField extends FormField<int?> {
  final String title;
  final Repository? foreignRepository;
  final String? Function(String?)? onValidate;
  final bool isRequired;

  PlusForeignFormField({
    super.key,
    required this.title,
    required this.foreignRepository,
    this.isRequired = false,
    this.onValidate,
    super.onSaved,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
  }) : super(
          builder: (state) {
            return _ForeignFormField(
              state: state,
              title: title,
              foreignRepository: foreignRepository,
              isRequired: isRequired,
            );
          },
          validator: ValidationBuilder(optional: !isRequired)
              .add(onValidate ?? (value) => null)
              .buildDyn(),
        );
}

class _ForeignFormField extends StatefulWidget {
  const _ForeignFormField({
    Key? key,
    required this.title,
    required this.foreignRepository,
    required this.state,
    this.isRequired = false,
  }) : super(key: key);
  final String? title;
  final FormFieldState<int?> state;
  final Repository? foreignRepository;
  final bool isRequired;

  @override
  State<_ForeignFormField> createState() => _ForeignFormFieldState();
}

class _ForeignFormFieldState extends State<_ForeignFormField> {
  late Field _selectedField;
  late List<Field> fields;
  List<Resource>? resources;
  Resource? _selectedResource;

  @override
  void initState() {
    fields = widget.foreignRepository!.empty
        .getFields()
        .where((element) => element.isSearchable)
        .toList();
    _selectedField = fields.first;
    init();
    super.initState();
  }

  void init() async {
    if (widget.state.value == null) return;
    var result = await widget.foreignRepository!.fetchOne(widget.state.value!);
    print(result);
    setState(() {
      _selectedResource = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Row(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    widget.title ?? "",
                    style: Get.context!.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Get.context!.theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (widget.isRequired)
                  Text(
                    "*",
                    style: Get.context!.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      height: 1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        if (_selectedResource == null)
          Row(
            children: [
              PlusDropDown<String?>(
                initialValue: _selectedField.name,
                onChanged: (value) {
                  setState(() {
                    _selectedField =
                        fields.firstWhere((element) => element.name == value);
                  });
                },
                items: [
                  for (var field in fields)
                    DropdownMenuItem<String?>(
                      value: field.name,
                      child: Text(
                        field.formattedName,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PlusFormField(
                  type: _selectedField.type,
                  onSubmitted: (value) async {
                    List<Resource> resources = await widget.foreignRepository!
                        .fetch(queries: {_selectedField.name: value});
                    setState(() {
                      this.resources = resources;
                    });
                  },
                ),
              ),
            ],
          ),
        if (_selectedResource == null && (resources?.isEmpty ?? false))
          const Text("No Result"),
        if (_selectedResource == null && (resources?.isNotEmpty ?? false))
          for (var resource in resources!)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedResource = resource;
                      resources = null;
                    });
                    widget.state.didChange(_selectedResource?.id);
                  },
                  child: Card(
                    shadowColor: Colors.grey,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.name ?? "-",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "${resource.toMap()[_selectedField.name]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  height: 1.2,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  )),
            ),
        if (_selectedResource != null)
          Card(
            shadowColor: Colors.grey,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedResource!.name ?? "-",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "${_selectedResource!.toMap()[_selectedField.name]}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedResource = null;
                      });
                      widget.state.didChange(_selectedResource?.id);
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ),
        if (widget.state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.state.errorText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: context.theme.errorColor,
              ),
            ),
          ),
      ],
    );
  }
}
