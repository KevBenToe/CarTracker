import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/models/document.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';
import 'package:vehicle_service_manager_frontend/repositories/document_repository.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<VehicleDocument>> _documentsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentsFuture = context.read<DocumentRepository>().getDocuments();
  }

  Future<void> _refresh() async {
    setState(() {
      _documentsFuture = context.read<DocumentRepository>().getDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<VehicleDocument>>(
        future: _documentsFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<VehicleDocument>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final List<VehicleDocument> documents =
              snapshot.data ?? <VehicleDocument>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(
                'Documents',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (documents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No documents available.'),
                  ),
                )
              else
                ...documents.map((VehicleDocument document) {
                  final String vehicleName =
                      vehicleProvider.findById(document.vehicleId)?.displayName ??
                          'Unknown vehicle';
                  final bool expiringSoon = document.expiryDate != null &&
                      document.expiryDate!.isBefore(
                        DateTime.now().add(const Duration(days: 45)),
                      );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Icon(
                            expiringSoon
                                ? Icons.warning_amber_outlined
                                : Icons.description_outlined,
                          ),
                        ),
                        title: Text(document.name),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$vehicleName • ${document.type}\nIssued ${DateFormat.yMMMd().format(document.issuedDate)}',
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (document.expiryDate != null)
                              Text(
                                'Expires ${DateFormat.yMMMd().format(document.expiryDate!)}',
                              ),
                            if (document.number != null) Text(document.number!),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

