import 'package:flutter/foundation.dart';

class AdminIdProvider extends ChangeNotifier {
  String? _orgId;
  String? _areaId;
  String? _subareaId;

  String? get orgId => _orgId;
  String? get areaId => _areaId;
  String? get subareaId => _subareaId;

  void setOrgId(String id) {
    _orgId = id;
    notifyListeners();
  }

  void setAreaId(String id) {
    _areaId = id;
    notifyListeners();
  }

  void setSubareaId(String id) {
    _subareaId = id;
    notifyListeners();
  }

  void clearOrgId() {
    _orgId = null;
    notifyListeners();
  }

  void clearAreaId() {
    _areaId = null;
    notifyListeners();
  }

  void clearSubareaId() {
    _subareaId = null;
    notifyListeners();
  }

  void clearAll() {
    _orgId = null;
    _areaId = null;
    _subareaId = null;
    notifyListeners();
  }
}
