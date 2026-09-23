import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

import 'anotacao.dart';
import 'nova_anotacao.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  // Os registros ficam em memória somente enquanto o aplicativo está aberto.
  final List<Anotacao> _anotacoes = [];
  bool _lanternaLigada = false;
  bool _processandoLanterna = false;

  Future<void> _alternarLanterna() async {
    if (_processandoLanterna) return;
    setState(() {
      _processandoLanterna = true;
    });

    try {
      final disponivel = await TorchLight.isTorchAvailable();
      if (!mounted) return;
      if (!disponivel) {
        setState(() {
          _lanternaLigada = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O dispositivo não possui lanterna disponível.'),
          ),
        );
        return;
      }

      if (_lanternaLigada) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      if (!mounted) return;
      setState(() {
        _lanternaLigada = !_lanternaLigada;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lanternaLigada = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível controlar a lanterna.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoLanterna = false;
        });
      }
    }
  }

  Future<void> _abrirNovaAnotacao() async {
    final anotacao = await Navigator.push<Anotacao>(
      context,
      MaterialPageRoute<Anotacao>(builder: (context) => const NovaAnotacao()),
    );

    if (!mounted || anotacao == null) return;

    setState(() {
      _anotacoes.add(anotacao);
    });
  }

  Future<void> _editarAnotacao(Anotacao anotacao) async {
    final atualizada = await Navigator.push<Anotacao>(
      context,
      MaterialPageRoute<Anotacao>(
        builder: (context) => NovaAnotacao(anotacao: anotacao),
      ),
    );

    if (!mounted || atualizada == null) return;
    final indice = _anotacoes.indexOf(anotacao);
    if (indice == -1) return;

    setState(() {
      _anotacoes[indice] = atualizada;
    });
  }

  Future<void> _excluirAnotacao(Anotacao anotacao) async {
    final tema = Theme.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tema.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Excluir anotação?'),
        content: Text(
          'Esta ação não poderá ser desfeita.',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: tema.colorScheme.onSurfaceVariant,
            ),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: tema.colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;
    setState(() {
      _anotacoes.remove(anotacao);
    });
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textoSecundario = tema.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRACE',
                style: tema.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record your journey.',
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: textoSecundario,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _anotacoes.isEmpty
                    ? Center(
                        child: Text(
                          'Ainda não existem registros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textoSecundario),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _anotacoes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final anotacao = _anotacoes[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          anotacao.titulo,
                                          style: tema.textTheme.titleMedium,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        tooltip: 'Opções da anotação',
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: textoSecundario,
                                          size: 20,
                                        ),
                                        color: tema.colorScheme.surface,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        onSelected: (opcao) {
                                          if (opcao == 'editar') {
                                            _editarAnotacao(anotacao);
                                          } else if (opcao == 'excluir') {
                                            _excluirAnotacao(anotacao);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'editar',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 20,
                                                  color: textoSecundario,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Editar',
                                                  style:
                                                      tema.textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'excluir',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                  color: tema.colorScheme.error,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Excluir',
                                                  style: tema
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: tema
                                                            .colorScheme
                                                            .error,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(anotacao.texto),
                                  const SizedBox(height: 16),
                                  Text(
                                    _formatarData(anotacao.dataCriacao),
                                    style: tema.textTheme.bodySmall?.copyWith(
                                      color: textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _processandoLanterna ? null : _alternarLanterna,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _lanternaLigada
                      ? tema.colorScheme.primary
                      : null,
                  foregroundColor: _lanternaLigada
                      ? tema.colorScheme.onPrimary
                      : null,
                ),
                icon: const Icon(Icons.flashlight_on_outlined),
                label: Text(_lanternaLigada ? 'Desligar lanterna' : 'Lanterna'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _abrirNovaAnotacao,
                icon: const Icon(Icons.add),
                label: const Text('Nova nota'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
