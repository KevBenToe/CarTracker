import 'package:vehicle_service_manager_frontend/models/document.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';
import 'package:vehicle_service_manager_frontend/services/demo_service.dart';

abstract class DocumentRepository {
  Future<List<VehicleDocument>> getDocuments();
  Future<List<VehicleDocument>> getDocumentsForVehicle(String vehicleId);
  Future<VehicleDocument> getDocument(String id);
  Future<VehicleDocument> createDocument(VehicleDocument document);
  Future<VehicleDocument> updateDocument(VehicleDocument document);
  Future<void> deleteDocument(String id);
}

class ApiDocumentRepository implements DocumentRepository {
  ApiDocumentRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<VehicleDocument>> getDocuments() async {
    final List<dynamic> data = await _apiService.getList('documents/');
    return data
        .whereType<Map>()
        .map(
          (Map item) => VehicleDocument.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<List<VehicleDocument>> getDocumentsForVehicle(String vehicleId) async {
    final List<VehicleDocument> all = await getDocuments();
    return all
        .where((VehicleDocument document) => document.vehicleId == vehicleId)
        .toList();
  }

  @override
  Future<VehicleDocument> getDocument(String id) async {
    final Map<String, dynamic> data = await _apiService.getObject('documents/$id/');
    return VehicleDocument.fromJson(data);
  }

  @override
  Future<VehicleDocument> createDocument(VehicleDocument document) async {
    final Map<String, dynamic> data =
        await _apiService.postObject('documents/', document.toJson());
    return VehicleDocument.fromJson(data);
  }

  @override
  Future<VehicleDocument> updateDocument(VehicleDocument document) async {
    final Map<String, dynamic> data =
        await _apiService.putObject('documents/${document.id}/', document.toJson());
    return VehicleDocument.fromJson(data);
  }

  @override
  Future<void> deleteDocument(String id) {
    return _apiService.delete('documents/$id/');
  }
}

class DemoDocumentRepository implements DocumentRepository {
  DemoDocumentRepository({required DemoService demoService}) : _demoService = demoService;

  final DemoService _demoService;
  final List<VehicleDocument> _documents = <VehicleDocument>[];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final List<Map<String, dynamic>> data = await _demoService.loadCollection(
      'documents',
      DemoSeeds.documents(),
    );
    _documents
      ..clear()
      ..addAll(data.map(VehicleDocument.fromJson));
    _initialized = true;
  }

  Future<void> _persist() async {
    await _demoService.saveCollection(
      'documents',
      _documents.map((VehicleDocument document) => document.toJson()).toList(),
    );
  }

  @override
  Future<List<VehicleDocument>> getDocuments() async {
    await _ensureInitialized();
    final List<VehicleDocument> values = List<VehicleDocument>.from(_documents);
    values.sort(
      (VehicleDocument a, VehicleDocument b) =>
          (a.expiryDate ?? a.issuedDate).compareTo(b.expiryDate ?? b.issuedDate),
    );
    return values;
  }

  @override
  Future<List<VehicleDocument>> getDocumentsForVehicle(String vehicleId) async {
    final List<VehicleDocument> all = await getDocuments();
    return all
        .where((VehicleDocument document) => document.vehicleId == vehicleId)
        .toList();
  }

  @override
  Future<VehicleDocument> getDocument(String id) async {
    await _ensureInitialized();
    return _documents.firstWhere((VehicleDocument document) => document.id == id);
  }

  @override
  Future<VehicleDocument> createDocument(VehicleDocument document) async {
    await _ensureInitialized();
    _documents.add(document);
    await _persist();
    return document;
  }

  @override
  Future<VehicleDocument> updateDocument(VehicleDocument document) async {
    await _ensureInitialized();
    final int index = _documents.indexWhere(
      (VehicleDocument item) => item.id == document.id,
    );
    if (index == -1) {
      throw StateError('Document ${document.id} not found.');
    }
    _documents[index] = document;
    await _persist();
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _ensureInitialized();
    _documents.removeWhere((VehicleDocument document) => document.id == id);
    await _persist();
  }
}

