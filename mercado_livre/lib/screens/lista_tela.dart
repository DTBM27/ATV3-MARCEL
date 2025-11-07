// ARQUIVO: lib/screens/lista_tela.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/anuncio.dart';
import '../helpers/db_helper.dart';
import 'form_tela.dart';

class ListaTela extends StatefulWidget {
  const ListaTela({super.key});

  @override
  State<ListaTela> createState() => _ListaTelaEstado();
}

class _ListaTelaEstado extends State<ListaTela> {
  List<Anunc> _itens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshItens();
  }

  Future<void> _refreshItens() async {
    setState(() => _isLoading = true);
    final data = await DbHelper.instance.readAll();
    if (mounted) {
      setState(() {
        _itens = data;
        _isLoading = false;
      });
    }
  }

  void _navigateToForm({Anunc? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormTela(item: item)),
    );

    if (result == true && mounted) {
      _refreshItens();
    }
  }

  Future<void> _deleteItem(Anunc item) async {
    await DbHelper.instance.delete(item.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anúncio removido'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              await DbHelper.instance.create(item);
              _refreshItens();
            },
          ),
        ),
      );
      _refreshItens();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo levemente cinza para destaque dos cards M3
      appBar: AppBar(
        title: const Text('Meus Anúncios'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itens.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Nenhum anúncio cadastrado',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _itens.length,
                  itemBuilder: (context, index) {
                    final item = _itens[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red[400],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) => _deleteItem(item),
                      child: _AnuncioCard(
                        item: item,
                        onTap: () => _navigateToForm(item: item),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        label: const Text('Vender'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _AnuncioCard extends StatelessWidget {
  final Anunc item;
  final VoidCallback onTap;

  const _AnuncioCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imagemPath != null && File(item.imagemPath!).existsSync();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: hasImage
                      ? DecorationImage(
                          image: FileImage(File(item.imagemPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${item.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.descricao,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}