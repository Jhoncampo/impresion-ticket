import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dispatch.dart';
import '../database/database_helper.dart';
import '../widgets/dispatch_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Dispatch> _dispatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDispatches();
  }

  Future<void> _loadDispatches() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final dispatches = await dbHelper.getAllDispatches();
    
    setState(() {
      _dispatches = dispatches;
      _isLoading = false;
    });
  }

  Future<void> _deleteDispatch(int id) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    await dbHelper.deleteDispatch(id);
    await _loadDispatches(); // Recargar la lista
  }

  Future<void> _clearAll() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Está seguro de eliminar todos los registros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
              await dbHelper.clearAllDispatches();
              await _loadDispatches();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historial de Despachos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_dispatches.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep),
                          onPressed: _clearAll,
                          tooltip: 'Limpiar todo',
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _dispatches.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay despachos registrados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _dispatches.length,
                          itemBuilder: (context, index) {
                            final dispatch = _dispatches[index];
                            return DispatchCard(
                              dispatch: dispatch,
                              onDelete: () => _deleteDispatch(dispatch.id!),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDispatches,
        child: const Icon(Icons.refresh),
        tooltip: 'Actualizar lista',
      ),
    );
  }
}