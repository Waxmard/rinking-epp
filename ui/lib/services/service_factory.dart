import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'list_service.dart';
import 'mock_list_service.dart';

/// A factory class that provides services based on configuration
class ServiceFactory {
  // Singleton instance
  static final ServiceFactory _instance = ServiceFactory._internal();
  
  // Private constructor
  ServiceFactory._internal();
  
  // Factory constructor to return the singleton instance
  factory ServiceFactory() {
    return _instance;
  }
  
  // Cached service instances
  late final dynamic _listService;
  
  /// Initialize the service factory 
  void initialize() {
    final useMock = dotenv.env['USE_MOCK_SERVICES']?.toLowerCase() == 'true';
    _listService = useMock ? MockListService() : ListService();
  }
  
  /// Get a list service implementation (real or mock)
  dynamic getListService() {
    return _listService;
  }
}