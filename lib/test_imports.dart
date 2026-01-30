import 'models/dispatch.dart';
import 'database/database_helper.dart';
import 'services/printer_service.dart';

void testImports() {
  print('Todas las importaciones funcionan correctamente');
  
  // Probar creación de objetos
  final dispatch = Dispatch(
    plate: 'ABC123',
    destination: 'Ciudad Test',
    estimatedPrice: 100.50,
    dispatchDate: DateTime.now(),
  );
  
  print('Dispatch creado: ${dispatch.plate}');
  
  final dbHelper = DatabaseHelper();
  print('DatabaseHelper inicializado');
  
  final printer = PrinterService();
  print('PrinterService inicializado');
}