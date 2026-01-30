class AppConstants {
  // Configuración de la impresora
  static const int printerDpi = 203;
  static const int printerWidth = 80;
  
  // Formato de fechas
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  
  // Validación de placas (regex básica - ajustar según país)
  static final plateRegex = RegExp(r'^[A-Z0-9]{6,8}$');
}