import 'package:flutter/material.dart';

class IdProvider extends ChangeNotifier {
  String _orgId = '';
  String _areaId = '';
  String _subareaId = '';

  String get orgId => _orgId;
  String get areaId => _areaId;
  String get subareaId => _subareaId;

  void setOrgId(String id) {
    _orgId = id;
    notifyListeners();
  }

  void clearOrgId() {
    _orgId = '';
    clearAreaId();
    notifyListeners();
  }

  void setAreaId(String id) {
    _areaId = id;
    notifyListeners();
  }

  void clearAreaId() {
    _areaId = '';
    clearSubareaId();
    notifyListeners();
  }

  void setSubareaId(String id) {
    _subareaId = id;
    notifyListeners();
  }

  void clearSubareaId() {
    _subareaId = '';
    notifyListeners();
  }
}
