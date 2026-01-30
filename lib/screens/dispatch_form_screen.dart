import 'package:flutter/material.dart';
import '../models/dispatch.dart';
import '../services/printer_service.dart';
import '../database/database_helper.dart';

class DispatchFormScreen extends StatefulWidget {
  const DispatchFormScreen({Key? key}) : super(key: key);

  @override
  _DispatchFormScreenState createState() => _DispatchFormScreenState();
}

class _DispatchFormScreenState extends State<DispatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _printerService = PrinterService();
  final _databaseHelper = DatabaseHelper();

  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isLoading = false;
  bool _printerConnected = false;

  @override
  void initState() {
    super.initState();
    _checkPrinterConnection();
  }

  Future<void> _checkPrinterConnection() async {
    try {
      await _printerService.initPrinter();
      setState(() {
        _printerConnected = true;
      });
    } catch (e) {
      setState(() {
        _printerConnected = false;
      });
      _showError('Impresora no disponible: $e');
    }
  }

  Future<void> _submitDispatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dispatch = Dispatch(
        plate: _plateController.text.trim().toUpperCase(),
        destination: _destinationController.text.trim(),
        estimatedPrice: double.parse(_priceController.text),
        dispatchDate: DateTime.now(),
      );

      final id = await _databaseHelper.insertDispatch(dispatch);
      dispatch.id = id;

      await _printerService.printDispatchTicket(dispatch);

      _showSuccess();
      _clearForm();

    } catch (e) {
      _showError('Error al procesar el despacho: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _plateController.clear();
    _destinationController.clear();
    _priceController.clear();
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Despacho registrado e impreso exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _testPrinter() async {
    try {
      await _printerService.printTestTicket();
      _showSuccessMessage('Prueba de impresión exitosa');
    } catch (e) {
      _showErrorMessage('Error en prueba de impresión: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado de la impresora
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _printerConnected ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _printerConnected ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _printerConnected ? Icons.print : Icons.print_disabled,
                    color: _printerConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _printerConnected
                          ? 'Impresora SUNMI V2 conectada'
                          : 'Impresora no disponible',
                      style: TextStyle(
                        color: _printerConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!_printerConnected)
                    TextButton(
                      onPressed: _checkPrinterConnection,
                      child: const Text('Reintentar'),
                    ),
                ],
              ),
            ),

            // Título
            Text(
              'Nuevo Despacho',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo Placa
            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Placa del Vehículo',
                hintText: 'Ej: ABC123',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la placa';
                }
                if (value.length < 4) {
                  return 'La placa debe tener al menos 4 caracteres';
                }
                return null;
              },
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),

            // Campo Destino
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino',
                hintText: 'Ej: Ciudad, Dirección',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el destino';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo Precio Estimado
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Precio Estimado (\$)',
                hintText: 'Ej: 150.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el precio';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Ingrese un valor numérico válido';
                }
                if (price <= 0) {
                  return 'El precio debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Botón de Despacho
            ElevatedButton(
              onPressed: _isLoading ? null : _submitDispatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'DESPACHAR E IMPRIMIR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 15),

            // Botón de Prueba de Impresión
            OutlinedButton(
              onPressed: _testPrinter,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.blue[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'PROBAR IMPRESORA',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Información adicional
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Instrucciones:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Complete todos los campos obligatorios'),
                Text('2. Verifique que la impresora esté conectada'),
                Text('3. Haga clic en "DESPACHAR E IMPRIMIR"'),
                Text('4. El ticket se imprimirá automáticamente'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}