import 'package:flutter/material.dart';
import '../models/dispatch.dart';

class DispatchCard extends StatelessWidget {
  final Dispatch dispatch;
  final VoidCallback onDelete;

  const DispatchCard({
    Key? key,
    required this.dispatch,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Placa: ${dispatch.plate}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Eliminar registro',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Destino: ${dispatch.destination}'),
            const SizedBox(height: 4),
            Text('Precio: \$${dispatch.estimatedPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${_formatDate(dispatch.dispatchDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}