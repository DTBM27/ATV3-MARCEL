// ARQUIVO: lib/models/anuncio.dart

class Anunc {
  final String id;
  final String titulo;
  final String descricao;
  final double preco;
  final String? imagemPath;

  Anunc({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    this.imagemPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'imagemPath': imagemPath,
    };
  }

  factory Anunc.fromMap(Map<String, dynamic> map) {
    return Anunc(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      imagemPath: map['imagemPath'] as String?,
    );
  }
}