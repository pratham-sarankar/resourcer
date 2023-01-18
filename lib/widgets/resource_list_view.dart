import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resourcer/data/abstracts/repository.dart';
import 'package:resourcer/data/abstracts/resource.dart';

import 'confirmation_dialog.dart';
import 'resource_dialog.dart';

class ResourceListView<T extends Resource> extends StatelessWidget {
  const ResourceListView({
    Key? key,
    required this.repository,
    required this.title,
    required this.description,
    required this.tileBuilder,
    this.canAdd = true,
  }) : super(key: key);
  final Repository<T> repository;
  final String title;
  final Widget Function(ListController, T) tileBuilder;
  final String description;
  final bool canAdd;
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ListController(repository),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Obx(
                  () => TextButton(
                    child: Row(
                      children: controller.isRefreshing.value
                          ? [
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  strokeWidth: 2,
                                ),
                              ),
                            ]
                          : const [
                              Icon(
                                CupertinoIcons.refresh,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text("Refresh"),
                            ],
                    ),
                    onPressed: () {
                      controller.reload();
                    },
                  ),
                ),
                if (canAdd)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TextButton(
                      child: Row(
                        children: const [
                          Icon(
                            CupertinoIcons.add,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text("Add"),
                        ],
                      ),
                      onPressed: () {
                        controller.insertTile();
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: controller.obx(
                (state) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: state!.length,
                  itemBuilder: (context, index) {
                    return tileBuilder(controller, state[index]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class ListController<T extends Resource> extends GetxController
    with StateMixin<List<T>> {
  final Repository<T> repository;
  final Function(Exception)? onError;

  ListController(this.repository, {this.onError});

  late int limit;
  late int offset;
  late RxBool isRefreshing;

  @override
  void onInit() {
    super.onInit();
    limit = 50;
    offset = 0;
    isRefreshing = false.obs;
    change([], status: RxStatus.loading());
    init();
  }

  void init() async {
    List<T> values = await repository.fetch(limit: limit, offset: offset);
    change(values,
        status: values.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  void insertTile() async {
    try {
      T? value = await Get.dialog(
          ResourceDialog<Resource>(resource: repository.empty));
      print(value?.toMap());
      if (value == null) return;
      isRefreshing.value = true;
      await repository.insert(value);
      isRefreshing.value = false;
      await reload();
    } catch (e) {
      isRefreshing.value = false;
    }
  }

  void destroyTile(T value) async {
    bool? sure = await Get.dialog(const ConfirmationDialog(
        message: "Are you sure you want to perform this action?"));
    if (!(sure ?? false)) return;
    isRefreshing.value = true;
    await repository.destroy(value);
    isRefreshing.value = false;
    await reload();
  }

  void updateTile(T value) async {
    T? updatedValue = await Get.dialog(ResourceDialog(resource: value));
    if (updatedValue == null) return;
    isRefreshing.value = true;
    await repository.update(updatedValue);
    isRefreshing.value = false;
    await reload();
  }

  void updateState(Future Function() updater) async {
    isRefreshing.value = true;
    await updater();
    isRefreshing.value = false;
    await reload();
  }

  Future reload() async {
    isRefreshing.value = true;
    List<T> values = await repository.fetch(limit: limit, offset: offset);
    isRefreshing.value = false;
    change(values,
        status: values.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}
