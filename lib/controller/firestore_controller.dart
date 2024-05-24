import 'package:flutter_interview_task/models/user_model.dart';
import 'package:flutter_interview_task/repository/firestore_repository.dart';

class FirestoreController {
  final FirestoreRepository _firestoreRepository = FirestoreRepository();

  void uploadUser(UserModel userModel) {
    _firestoreRepository.uploadUser(userModel);
  }

  void updateUser(UserModel userModel) {
    _firestoreRepository.updateUser(userModel);
  }

  Future<UserModel?> getUserModel() {
    return _firestoreRepository.getUser();
  }
}
