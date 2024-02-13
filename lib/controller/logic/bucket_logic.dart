import 'package:pewobu/controller/logic/base_todo_provider.dart';

class BucketLogic extends BaseTodoProvider {
  @override
  Future<void> saveData(String category) async {
    await super.saveData('bucket');
  }
}
