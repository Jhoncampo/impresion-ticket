import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../models/dispatch.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  Future<Uint8List> _loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  /// INIT
  Future<void> initPrinter() async {
    //bool? isConnected = await SunmiPrinter.bindingPrinter();

    // Todo: pendiente por validar estado
    // if (isConnected != true) {
    //   throw Exception('No se pudo conectar con la impresora SUNMI');
    // }

    await SunmiPrinter.initPrinter();
  }

  Uint8List _processImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    final resized = img.copyResize(image!, width: 300);
    final grayscale = img.grayscale(resized);
    return Uint8List.fromList(img.encodePng(grayscale));
  }

  Uint8List _centerImage(Uint8List bytes) {
    final original = img.decodeImage(bytes)!;

    final resized = img.copyResize(original, width: 200);

    final canvas = img.Image(width: 384, height: resized.height);

    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    final offsetX = (384 - resized.width) ~/ 2;

    img.compositeImage(canvas, resized, dstX: offsetX, dstY: 0);

    return Uint8List.fromList(img.encodePng(canvas));
  }

  Future<void> _printLogo() async {
    final bytes = await _loadAssetImage('assets/images/logo-ctm-black.png');
    final centered = _centerImage(bytes);

    await SunmiPrinter.printImage(centered);

    await SunmiPrinter.lineWrap(1);
  }

  Future<void> printDispatchTicket(Dispatch dispatch) async {
    try {
      await initPrinter();
      await SunmiPrinter.startTransactionPrint(true);

      await _printCenter('DESPACHO DE VEHÍCULO\n', bold: true);

      await _printCenter('========================\n\n');

      await _printLeft('ORIGEN: ${dispatch.origin}\n');
      await _printLeft('DESTINO: ${dispatch.destination}\n');
      await _printLeft('PLACA: ${dispatch.plate}\n');
      if (dispatch.estimatedPrice != 0) {
        await _printLeft(
          'PRECIO ESTIMADO: \$${dispatch.estimatedPrice?.toStringAsFixed(2)}\n',
        );
      }
      await _printLeft('FECHA: ${_formatDate(dispatch.dispatchDate)}\n');
      await _printLeft('HORA: ${_formatTime(dispatch.dispatchDate)}\n\n');

      await _printCenter('------------------------\n\n');

      await _printCenter('Gracias por su preferencia\n');
      await _printCenter('Despacho registrado exitosamente\n\n');

      await _printLogo();

      await SunmiPrinter.lineWrap(3);
      //await SunmiPrinter.cut();
      //await SunmiPrinter.endTransactionPrint();
      await _printCenter(' \n\n');

      await _printCenter('Cootransmede\n', bold: true);
      await _printCenter(' \n\n');
      await _printCenter(' \n\n');
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      throw Exception('❌ Error al imprimir despacho: $e');
    }
  }

  /// PRINT TEST
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

  /// HELPERS DE IMPRESIÓN
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
    bool bold = true,
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

  /// FORMATTERS
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
