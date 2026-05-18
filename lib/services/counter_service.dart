import '../repositories/counter_repository.dart';

class CounterService {
  final CounterRepository _repository;

  CounterService({CounterRepository? repository})
      : _repository = repository ?? CounterRepository();

  Future<int> getInitialCount() async {
    return await _repository.getInitialCount();
  }

  Future<void> saveCount(int count) async {
    await _repository.saveCount(count);
  }
  
}
