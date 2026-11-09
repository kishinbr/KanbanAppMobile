import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Componentes visuais reaproveitados pelas telas.

String limparErro(Object e) => '$e'.replaceAll('Exception: ', '');

void mostrarMensagem(BuildContext context, Object mensagem) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(limparErro(mensagem))));
}

/// Logo do app: quadrado preto arredondado com o ícone de kanban.
class AppLogo extends StatelessWidget {
  final double tamanho;
  const AppLogo({super.key, this.tamanho = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: AppCores.primaria,
        borderRadius: BorderRadius.circular(tamanho * 0.3),
      ),
      child: Icon(Icons.view_kanban_rounded,
          color: Colors.white, size: tamanho * 0.5),
    );
  }
}

/// Caixa branca com cantos arredondados e sombra leve. Pode ser tocável.
class Superficie extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double raio;
  final List<BoxShadow> sombra;
  final Color cor;

  const Superficie({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.raio = 18,
    this.sombra = AppSombras.suave,
    this.cor = AppCores.superficie,
  });

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(raio);
    return DecoratedBox(
      decoration:
          BoxDecoration(color: cor, borderRadius: borda, boxShadow: sombra),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borda,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Caixa vermelha discreta para mensagens de erro em formulários.
class CaixaErro extends StatelessWidget {
  final String mensagem;
  const CaixaErro(this.mensagem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppCores.perigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppCores.perigo, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(mensagem,
                style: const TextStyle(
                    color: AppCores.perigo,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Botão principal preto, largura total, com estado de carregamento.
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool carregando;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(texto),
      ),
    );
  }
}

/// Avatar com a inicial do nome em tom pastel (cor definida pelo nome).
class AvatarInicial extends StatelessWidget {
  final String nome;
  final double tamanho;
  final double? raio;
  final Color? contorno;

  const AvatarInicial(this.nome,
      {super.key, this.tamanho = 40, this.raio, this.contorno});

  @override
  Widget build(BuildContext context) {
    final par = AppCores.pasteis[nome.hashCode.abs() % AppCores.pasteis.length];
    final inicial = nome.trim().isEmpty ? '?' : nome.trim()[0].toUpperCase();
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: par.$1,
        borderRadius: BorderRadius.circular(raio ?? tamanho),
        border: contorno == null ? null : Border.all(color: contorno!, width: 2),
      ),
      child: Text(
        inicial,
        style: TextStyle(
          color: par.$2,
          fontWeight: FontWeight.w700,
          fontSize: tamanho * 0.4,
        ),
      ),
    );
  }
}

/// Avatares sobrepostos (até 3) + contador do restante.
class PilhaAvatares extends StatelessWidget {
  final List<String> nomes;
  const PilhaAvatares(this.nomes, {super.key});

  @override
  Widget build(BuildContext context) {
    const tam = 30.0;
    final visiveis = nomes.take(3).toList();
    final resto = nomes.length - visiveis.length;
    final itens = <Widget>[
      for (final n in visiveis)
        AvatarInicial(n, tamanho: tam, contorno: AppCores.fundo),
      if (resto > 0)
        Container(
          width: tam,
          height: tam,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppCores.coluna,
            shape: BoxShape.circle,
            border: Border.all(color: AppCores.fundo, width: 2),
          ),
          child: Text('+$resto',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppCores.textoSuave)),
        ),
    ];
    return SizedBox(
      height: tam,
      width: itens.isEmpty ? 0 : tam + (itens.length - 1) * (tam - 8),
      child: Stack(
        children: [
          for (var i = 0; i < itens.length; i++)
            Positioned(left: i * (tam - 8), child: itens[i]),
        ],
      ),
    );
  }
}

/// Código de compartilhamento que copia ao tocar.
class CodigoCopiavel extends StatelessWidget {
  final String codigo;
  const CodigoCopiavel(this.codigo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppCores.campo,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: codigo));
          if (context.mounted) mostrarMensagem(context, 'Código copiado');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                codigo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppCores.texto,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.copy_rounded,
                  size: 14, color: AppCores.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela vazia amigável (sem quadros, sem colunas, erro...).
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;
  final Widget? acao;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppCores.superficie,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppSombras.suave,
            ),
            child: Icon(icone, size: 34, color: AppCores.texto),
          ),
          const SizedBox(height: 22),
          Text(titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2)),
          if (descricao != null) ...[
            const SizedBox(height: 8),
            Text(descricao!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppCores.textoSuave, fontSize: 14.5, height: 1.45)),
          ],
          if (acao != null) ...[const SizedBox(height: 22), acao!],
        ],
      ),
    );
  }
}

List<Widget> acoesDialogo(BuildContext ctx,
    {required String confirmar,
    required VoidCallback aoConfirmar,
    Color? cor}) {
  return [
    TextButton(
      onPressed: () => Navigator.pop(ctx),
      style: TextButton.styleFrom(foregroundColor: AppCores.textoSuave),
      child: const Text('Cancelar'),
    ),
    FilledButton(
      onPressed: aoConfirmar,
      style: FilledButton.styleFrom(
        minimumSize: const Size(96, 46),
        backgroundColor: cor,
      ),
      child: Text(confirmar),
    ),
  ];
}

/// Diálogo com um único campo de texto. Retorna o texto ou null.
Future<String?> dialogoTexto(
  BuildContext context, {
  required String titulo,
  required String dica,
  String inicial = '',
  String confirmar = 'Salvar',
  bool maiusculas = false,
}) {
  final controller = TextEditingController(text: inicial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: maiusculas
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
        decoration: InputDecoration(hintText: dica),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: acoesDialogo(ctx,
          confirmar: confirmar,
          aoConfirmar: () => Navigator.pop(ctx, controller.text)),
    ),
  );
}

/// Diálogo de confirmação (botão vermelho). Retorna true se confirmou.
Future<bool> dialogoConfirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String confirmar,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: AppCores.textoSuave),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppCores.perigo,
            minimumSize: const Size(96, 46),
          ),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return r == true;
}

/// Item de menu (popup) com ícone.
PopupMenuItem<String> itemMenu(String valor, IconData icone, String texto,
    {bool perigoso = false}) {
  final cor = perigoso ? AppCores.perigo : AppCores.texto;
  return PopupMenuItem<String>(
    value: valor,
    child: Row(
      children: [
        Icon(icone, size: 20, color: cor),
        const SizedBox(width: 12),
        Text(texto, style: TextStyle(color: cor)),
      ],
    ),
  );
}
