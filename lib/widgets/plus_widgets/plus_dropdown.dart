import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:resourcer/data/utils/extensions/validator_extension.dart';

class PlusDropDown<T> extends StatefulWidget {
  const PlusDropDown({
    Key? key,
    required this.items,
    this.title,
    this.isRequired = false,
    this.onChanged,
    this.initialValue,
    this.onValidate,
    this.onSaved,
  }) : super(key: key);
  final List<DropdownMenuItem<T?>> items;
  final T? initialValue;
  final void Function(dynamic)? onChanged;
  final String? Function(T?)? onValidate;
  final String? title;
  final bool isRequired;
  final void Function(T?)? onSaved;

  @override
  PlusDropDownState<T?> createState() => PlusDropDownState<T?>();
}

class PlusDropDownState<T> extends State<PlusDropDown> {
  late T? value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
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
        DropdownButtonHideUnderline(
          child: IntrinsicWidth(
            child: DropdownButtonFormField2(
              isExpanded: true,
              items: widget.items,
              value: value,
              onChanged: (selectedValue) {
                if (widget.onChanged == null) return;
                widget.onChanged!(selectedValue);
                setState(() {
                  value = selectedValue;
                });
              },
              icon: Icon(Icons.arrow_drop_down_rounded,
                  size: 25, color: value == null ? Colors.grey : Colors.black),
              iconSize: 14,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              buttonHeight: 35,
              buttonPadding: const EdgeInsets.only(left: 5, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.theme.outlinedButtonTheme.style!.side!
                      .resolve({})!.color,
                ),
              ),
              buttonElevation: 0,
              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 10, right: 10),
              dropdownMaxHeight: 200,
              dropdownPadding: null,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              dropdownElevation: 8,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              offset: const Offset(0, 0),
              validator: ValidationBuilder(optional: !widget.isRequired)
                  .add(widget.onValidate ?? (value) => null)
                  .buildDyn(),
              onSaved: widget.onSaved,
            ),
          ),
        ),
      ],
    );
  }
}
