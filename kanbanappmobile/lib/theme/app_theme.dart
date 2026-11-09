import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta do app (tema claro e limpo). Mudou aqui, muda no app inteiro.
class AppCores {
  static const fundo = Color(0xFFF6F5F2); // off-white quente
  static const superficie = Color(0xFFFFFFFF); // cartões, diálogos
  static const coluna = Color(0xFFEDECE8); // fundo das colunas
  static const campo = Color(0xFFF1F0EC); // fundo dos campos de texto
  static const borda = Color(0xFFE3E1DC);
  static const texto = Color(0xFF1C1C1E);
  static const textoSuave = Color(0xFF76767E);
  static const textoFraco = Color(0xFFA3A3AA);
  static const primaria = Color(0xFF1C1C1E); // destaque: preto
  static const perigo = Color(0xFFE5484D);

  /// Cores das bolinhas das colunas, usadas em sequência.
  static const colunas = [
    Color(0xFFFF9F43),
    Color(0xFF4D96FF),
    Color(0xFF9B5DE5),
    Color(0xFF2EC4B6),
    Color(0xFFF15BB5),
    Color(0xFFFFC43D),
  ];

  /// Pares (fundo, texto) em tons pastel para avatares.
  static const pasteis = [
    (Color(0xFFFFE1C2), Color(0xFF8A4B00)),
    (Color(0xFFCFE4FF), Color(0xFF1D4F80)),
    (Color(0xFFE3D7FF), Color(0xFF4B2A99)),
    (Color(0xFFCDEFE9), Color(0xFF0F6B5C)),
    (Color(0xFFFFD6E8), Color(0xFF8C1D53)),
    (Color(0xFFFFF0B8), Color(0xFF7A5A00)),
  ];
}

class AppSombras {
  static const suave = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const flutuante = [
    BoxShadow(color: Color(0x26000000), blurRadius: 28, offset: Offset(0, 14)),
  ];
}

class AppTheme {
  static ThemeData get claro {
    const scheme = ColorScheme.light(
      primary: AppCores.primaria,
      onPrimary: Colors.white,
      secondary: AppCores.primaria,
      onSecondary: Colors.white,
      surface: AppCores.superficie,
      onSurface: AppCores.texto,
      surfaceContainerHighest: AppCores.campo,
      outline: AppCores.borda,
      outlineVariant: AppCores.borda,
      error: AppCores.perigo,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
    );

    OutlineInputBorder bordaCampo(Color cor, [double largura = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppCores.fundo,
      textTheme: base.textTheme.apply(
        bodyColor: AppCores.texto,
        displayColor: AppCores.texto,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppCores.fundo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppCores.texto),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppCores.texto,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppCores.campo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        labelStyle: const TextStyle(color: AppCores.textoSuave),
        floatingLabelStyle: const TextStyle(color: AppCores.texto),
        hintStyle: const TextStyle(color: AppCores.textoFraco),
        prefixIconColor: AppCores.textoSuave,
        suffixIconColor: AppCores.textoSuave,
        border: bordaCampo(Colors.transparent),
        enabledBorder: bordaCampo(Colors.transparent),
        focusedBorder: bordaCampo(AppCores.texto, 1.5),
        errorBorder: bordaCampo(AppCores.perigo),
        focusedErrorBorder: bordaCampo(AppCores.perigo, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppCores.primaria,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppCores.primaria.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(64, 54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppCores.texto,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppCores.texto),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppCores.superficie,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppCores.texto,
        ),
        contentTextStyle: const TextStyle(
            fontSize: 14.5, color: AppCores.textoSuave, height: 1.45),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppCores.superficie,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black26,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontSize: 15, color: AppCores.texto, fontWeight: FontWeight.w500),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppCores.superficie,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppCores.borda,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppCores.texto,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppCores.primaria,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 4,
        hoverElevation: 6,
        highlightElevation: 6,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppCores.texto),
      dividerTheme:
          const DividerThemeData(color: AppCores.borda, thickness: 1),
    );
  }
}
