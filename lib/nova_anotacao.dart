import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'anotacao.dart';

class NovaAnotacao extends StatefulWidget {
  const NovaAnotacao({super.key, this.anotacao});

  final Anotacao? anotacao;

  @override
  State<NovaAnotacao> createState() => _NovaAnotacaoState();
}

class _NovaAnotacaoState extends State<NovaAnotacao> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  final FocusNode _tituloFocusNode = FocusNode();
  final FocusNode _textoFocusNode = FocusNode();
  final SpeechToText _speech = SpeechToText();
  bool _ouvindo = false;
  bool _processandoVoz = false;

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.anotacao?.titulo ?? '';
    _textoController.text = widget.anotacao?.texto ?? '';
  }

  void _mostrarMensagemVoz() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reconhecimento de voz indisponível. Verifique a permissão do microfone e tente novamente.',
        ),
      ),
    );
  }

  void _atualizarStatusVoz(String status) {
    if (!mounted) return;
    setState(() {
      _ouvindo = _speech.isListening;
    });
  }

  void _tratarErroVoz(SpeechRecognitionError erro) {
    if (!mounted) return;
    setState(() {
      _ouvindo = false;
    });
    _mostrarMensagemVoz();
  }

  Future<void> _alternarDitado() async {
    if (_processandoVoz) return;
    final controller = _tituloFocusNode.hasFocus
        ? _tituloController
        : _textoController;
    setState(() {
      _processandoVoz = true;
    });

    try {
      if (_ouvindo) {
        await _speech.stop();
        return;
      }

      final disponivel = await _speech.initialize(
        onStatus: _atualizarStatusVoz,
        onError: _tratarErroVoz,
      );
      if (!mounted) return;
      if (!disponivel) {
        _mostrarMensagemVoz();
        return;
      }

      // O plugin reutiliza a instância; atualizamos os callbacks ao reabrir a tela.
      _speech.statusListener = _atualizarStatusVoz;
      _speech.errorListener = _tratarErroVoz;

      final idiomas = await _speech.locales();
      if (!mounted) return;
      String? idioma;
      for (final item in idiomas) {
        if (item.localeId.replaceAll('-', '_').toLowerCase() == 'pt_br') {
          idioma = item.localeId;
          break;
        }
      }

      // Cada resultado contém a frase inteira: mantemos uma base fixa por ditado.
      final textoAnterior = controller.text;
      var ultimoTexto = textoAnterior;
      final separador =
          textoAnterior.isEmpty || RegExp(r'\s$').hasMatch(textoAnterior)
          ? ''
          : ' ';

      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: idioma,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
        onResult: (resultado) {
          if (!mounted || resultado.recognizedWords.isEmpty) return;
          // Um resultado atrasado não deve substituir uma edição manual.
          if (controller.text != ultimoTexto) return;
          final texto = '$textoAnterior$separador${resultado.recognizedWords}';
          ultimoTexto = texto;
          controller.value = TextEditingValue(
            text: texto,
            selection: TextSelection.collapsed(offset: texto.length),
          );
        },
      );
    } catch (_) {
      _mostrarMensagemVoz();
    } finally {
      if (mounted) {
        setState(() {
          _processandoVoz = false;
          _ouvindo = _speech.isListening;
        });
      }
    }
  }

  @override
  void dispose() {
    _speech.statusListener = null;
    _speech.errorListener = null;
    _speech.cancel();
    _tituloController.dispose();
    _textoController.dispose();
    _tituloFocusNode.dispose();
    _textoFocusNode.dispose();
    super.dispose();
  }

  void _salvar() {
    final titulo = _tituloController.text.trim();
    final texto = _textoController.text.trim();

    if (titulo.isEmpty || texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o título e o texto da anotação.'),
        ),
      );
      return;
    }

    final anotacao = Anotacao(
      titulo: titulo,
      texto: texto,
      dataCriacao: widget.anotacao?.dataCriacao ?? DateTime.now(),
    );

    Navigator.pop<Anotacao>(context, anotacao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anotacao == null ? 'Nova nota' : 'Editar anotação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _tituloController,
                focusNode: _tituloFocusNode,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textoController,
                focusNode: _textoFocusNode,
                readOnly: _ouvindo || _processandoVoz,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                minLines: 8,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Anotação',
                  hintText: 'Registre sua experiência...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFieldTapRegion(
                      child: OutlinedButton.icon(
                        onPressed: _processandoVoz ? null : _alternarDitado,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _ouvindo
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          foregroundColor: _ouvindo
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                        icon: Icon(_ouvindo ? Icons.stop : Icons.mic_none),
                        label: Text(_ouvindo ? 'Parar' : 'Ditar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _salvar,
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
