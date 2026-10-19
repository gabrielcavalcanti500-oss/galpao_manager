import '../../../compras/domain/entities/material_model.dart';
import '../../../estoque/data/repositories/estoque_repository.dart';

class RetiradaService {
  final EstoqueRepository _estoqueRepository;

  RetiradaService({EstoqueRepository? estoqueRepository})
    : _estoqueRepository = estoqueRepository ?? EstoqueRepository();

  Future<double> consultarEstoque(MaterialModel material) {
    return _estoqueRepository.calcularEstoque(material);
  }

  Future<void> validarRetirada({
    required MaterialModel material,
    required double quantidade,
  }) async {
    if (quantidade <= 0) {
      throw ArgumentError('A quantidade retirada deve ser maior que zero.');
    }

    final estoqueDisponivel = await _estoqueRepository.calcularEstoque(
      material,
    );

    if (estoqueDisponivel <= 0) {
      throw StateError('Não existe estoque disponível de ${material.nome}.');
    }

    if (quantidade > estoqueDisponivel) {
      final unidade = material.vendidoPorUnidade ? 'unidades' : 'kg';

      throw StateError(
        'Estoque insuficiente de ${material.nome}. '
        'Disponível: ${estoqueDisponivel.toStringAsFixed(2)} '
        '$unidade.',
      );
    }
  }
}
