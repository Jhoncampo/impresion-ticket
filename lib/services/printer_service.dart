import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../models/dispatch.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  
  /// INIT
  Future<void> initPrinter() async {
    bool? isConnected = await SunmiPrinter.bindingPrinter();

    // if (isConnected != true) {
    //   throw Exception('No se pudo conectar con la impresora SUNMI');
    // }

    await SunmiPrinter.initPrinter();
  }

  
  /// PRINT DISPATCH TICKET
  Future<void> printDispatchTicket(Dispatch dispatch) async {
    try {
      await initPrinter();
      await SunmiPrinter.startTransactionPrint(true);

      // ---- HEADER ----
      await _printCenter(
        'DESPACHO DE VEHÍCULO\n',
        bold: true,
        
      );

      await _printCenter('========================\n\n');

      // ---- BODY ----
      await _printLeft('ORIGEN: Terminal del Norte\n');
      await _printLeft('DESTINO: ${dispatch.destination}\n');
      await _printLeft('PLACA: ${dispatch.plate}\n');
      await _printLeft(
          'PRECIO ESTIMADO: \$${dispatch.estimatedPrice.toStringAsFixed(2)}\n');
      await _printLeft('FECHA: ${_formatDate(dispatch.dispatchDate)}\n');
      await _printLeft('HORA: ${_formatTime(dispatch.dispatchDate)}\n\n');

      // ---- FOOTER ----
      await _printCenter('------------------------\n\n');

      await _printCenter('Gracias por su preferencia\n');
      await _printCenter('Despacho registrado exitosamente\n\n');
      

      // ---- QR ----
      await SunmiPrinter.printQRCode(
        '6042659692',
        style: SunmiQrcodeStyle(align: SunmiPrintAlign.CENTER)
      );

      await SunmiPrinter.lineWrap(3);
      //await SunmiPrinter.cut(); 
      //await SunmiPrinter.endTransactionPrint();
      await _printCenter(' \n\n');

      await _printCenter(
        'COOTRANSMEDE\n',
        bold: true,
        
        
      );
       await _printCenter(' \n\n');
      await _printCenter(' \n\n');
      await SunmiPrinter.lineWrap(3);

    } catch (e) {
      throw Exception('❌ Error al imprimir despacho: $e');
    }
  }

  /// =============================
  /// PRINT TEST
  /// =============================
  Future<void> printTestTicket() async {
    await initPrinter();
   // await SunmiPrinter.startTransactionPrint(true);

    await _printCenter(
      'PRUEBA DE IMPRESIÓN\n',
      bold: true,
     // size: SunmiFontSize.LG,
    );

    await _printLeft('Este es un ticket de prueba\n');
    await _printLeft('SUNMI Printer OK ✅\n');
    await _printLeft('Fecha: ${_formatDate(DateTime.now())}\n');

    await SunmiPrinter.lineWrap(4);
   // await SunmiPrinter.endTransactionPrint();
  }

  /// =============================
  /// HELPERS DE IMPRESIÓN
  /// =============================
  Future<void> _printCenter(
    String text, {
    bool bold = false,
   // SunmiFontSize size = SunmiFontSize.MD,
  }) async {
    await SunmiPrinter.printText(
      text,
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
        bold: bold,
       // fontSize: size,
      ),
    );
  }

  Future<void> _printLeft(
    String text, {
    bool bold = true
    //SunmiFontSize size = SunmiFontSize.MD,
  }) async {
    await SunmiPrinter.printText(
      text,
      style: SunmiTextStyle(
        align: SunmiPrintAlign.LEFT,
        //fontSize: size,
      ),
    );
  }

  /// =============================
  /// FORMATTERS
  /// =============================
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
