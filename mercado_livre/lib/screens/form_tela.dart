// ARQUIVO: lib/screens/form_tela.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/anuncio.dart';
import '../helpers/db_helper.dart';

class FormTela extends StatefulWidget {
  final Anunc? item;
  const FormTela({super.key, this.item});

  @override
  State<FormTela> createState() => _FormTelaEstado();
}

class _FormTelaEstado extends State<FormTela> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _precoCtrl;
  String? _imagemPath;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.item?.titulo);
    _descCtrl = TextEditingController(text: widget.item?.descricao);
    _precoCtrl = TextEditingController(text: widget.item?.preco.toStringAsFixed(2));
    _imagemPath = widget.item?.imagemPath;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAnuncio() async {
    if (!_formKey.currentState!.validate()) return;

    final preco = double.tryParse(_precoCtrl.text.replaceAll(',', '.'));
    if (preco == null) return;

    final anuncio = Anunc(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      descricao: _descCtrl.text.trim(),
      preco: preco,
      imagemPath: _imagemPath,
    );

    if (isEditing) {
      await DbHelper.instance.update(anuncio);
    } else {
      await DbHelper.instance.create(anuncio);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _imagemPath = picked.path);
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  void _shareAnuncio() {
    if (!isEditing) return;
    final text = Uri.encodeFull(
        'Confira "${widget.item!.titulo}" por apenas R\$ ${widget.item!.preco.toStringAsFixed(2)}!');

    showModalBottomSheet(
      context: context,
      showDragHandle: true, // Padrão M3
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('WhatsApp'),
              onTap: () => launchUrlString('https://wa.me/?text=$text',
                  mode: LaunchMode.externalApplication),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('E-mail'),
              onTap: () => launchUrlString('mailto:?subject=Anúncio&body=$text'),
            ),
            ListTile(
              leading: const Icon(Icons.sms_outlined),
              title: const Text('SMS'),
              onTap: () => launchUrlString('sms:?body=$text'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Anúncio' : 'Novo Anúncio'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareAnuncio,
              tooltip: 'Compartilhar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título do anúncio',
                  hintText: 'Ex: Samsung Galaxy S23...',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (v) => v?.isEmpty == true ? 'Informe o título' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _precoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (v) => v?.isEmpty == true ? 'Informe o preço' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Detalhes do produto, estado de conservação...',
                  border: OutlineInputBorder(),
                  filled: true,
                  alignLabelWithHint: true,
                ),
                validator: (v) => v?.isEmpty == true ? 'Informe a descrição' : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        // FilledButton é o botão padrão principal do Material 3
        child: FilledButton(
          onPressed: _saveAnuncio,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('SALVAR ANÚNCIO', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _imagemPath != null && File(_imagemPath!).existsSync();
    return Center(
      child: InkWell(
        onTap: () => _showImageSourceModal(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            image: hasImage
                ? DecorationImage(
                    image: FileImage(File(_imagemPath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !hasImage
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Adicionar foto', style: TextStyle(color: Colors.grey)),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}