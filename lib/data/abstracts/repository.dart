import 'package:get/get.dart';
import 'package:resourcer/data/abstracts/provider.dart';
import 'package:resourcer/data/abstracts/resource.dart';

abstract class Repository<T extends Resource> extends Provider<T> {
  Repository({required super.path});

  @override
  Future insert(T value) async {
    await post('/', value.toMap());
  }

  @override
  Future<List<T>> fetch(
      {int limit = 100,
      int offset = 0,
      Map<String, dynamic> queries = const {}}) async {
    String query = queries.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList()
        .join("&");
    Response response = await get('/?$query', headers: {
      "limit": limit.toString(),
      "offset": offset.toString(),
    });
    List data = response.body["data"];
    return data.map<T>((map) => empty.fromMap(map)).toList();
  }

  @override
  Future<T> fetchOne(int id) async {
    Response response = await get('/$id');
    return empty.fromMap(response.body["data"]);
  }

  @override
  Future update(T value) async {
    await put('/${value.id}', value.toMap());
  }

  @override
  Future destroy(T value) async {
    await delete('/${value.id}');
  }

  @override
  Future destroyMany(List<T> value) async {
    List ids = value.map((branch) => branch.id).toList();
    await delete('/', query: {'ids': ids});
  }

  T get empty;
}
