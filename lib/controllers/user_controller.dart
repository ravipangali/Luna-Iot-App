import 'package:get/get.dart';
import 'package:luna_iot/api/services/role_api_service.dart';
import 'package:luna_iot/api/services/user_api_service.dart';

class UserController extends GetxController {
  final UserApiService _userApiService;
  final RoleApiService _roleApiService;

  var users = <dynamic>[].obs;
  var roles = <dynamic>[].obs;
  var isLoading = false.obs;

  UserController(this._userApiService, this._roleApiService);

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadRoles();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userApiService.getAllUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRoles() async {
    try {
      roles.value = await _roleApiService.getAllRoles();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load roles');
    }
  }

  Future<void> createUser(
    String name,
    String phone,
    String password,
    int roleId,
    bool isActive,
  ) async {
    try {
      isLoading.value = true;
      await _userApiService.createUser({
        'name': name,
        'phone': phone,
        'password': password,
        'roleId': roleId,
        'status': isActive ? 'ACTIVE' : 'INACTIVE',
      });
      await loadUsers();
      Get.back();
      Get.snackbar('Success', 'User created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String phone, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _userApiService.updateUser(phone, data);
      await loadUsers();
      Get.back();
      Get.snackbar('Success', 'User updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String phone) async {
    try {
      isLoading.value = true;
      await _userApiService.deleteUser(phone);
      await loadUsers();
      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user');
    } finally {
      isLoading.value = false;
    }
  }
}
