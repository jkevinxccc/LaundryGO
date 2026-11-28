/// Hasil dari operasi Partition
class PartitionResult<T> {
  /// Elemen yang nilainya lebih kecil atau sama dengan pivot (sisi kiri)
  final List<T> left;

  /// Elemen yang nilainya lebih besar dari pivot (sisi kanan)
  final List<T> right;

  /// Nilai pivot patokan yang digunakan
  final int pivotValue;

  /// Gabungan elemen [left..., right...] yang tersusun rapi berdasarkan partisi
  final List<T> partitionedList;

  const PartitionResult({
    required this.left,
    required this.right,
    required this.pivotValue,
    required this.partitionedList,
  });

  int get leftCount => left.length;
  int get rightCount => right.length;
  int get totalCount => left.length + right.length;
}

/// Helper algoritma Partition (Konsep Inti QuickSort)
/// Operasi Partition membagi sekumpulan data menjadi dua bagian berdasarkan
/// sebuah nilai patokan yang disebut pivot. Semua elemen yang lebih kecil atau sama
/// dengan pivot diletakkan di sisi kiri, sedangkan elemen yang lebih besar diletakkan di sisi kanan.
class PartitionHelper {
  /// Menghitung pivot default dari sekumpulan data
  /// Menggunakan nilai median dari data harga yang ada.
  static int calculateDefaultPivot<T>(
    List<T> items,
    int Function(T item) valueExtractor,
  ) {
    if (items.isEmpty) return 20000;

    final values = items.map(valueExtractor).toList()..sort();
    final mid = values.length ~/ 2;
    return values[mid];
  }

  /// Menjalankan operasi Partition:
  /// Membagi sekumpulan data menjadi dua bagian berdasarkan nilai patokan [pivotValue]:
  /// - Sisi Kiri (Left): Semua elemen dengan nilai <= pivot
  /// - Sisi Kanan (Right): Semua elemen dengan nilai > pivot
  static PartitionResult<T> partition<T>({
    required List<T> items,
    required int Function(T item) valueExtractor,
    int? customPivot,
  }) {
    if (items.isEmpty) {
      return PartitionResult<T>(
        left: [],
        right: [],
        pivotValue: customPivot ?? 20000,
        partitionedList: [],
      );
    }

    final pivot = customPivot ?? calculateDefaultPivot(items, valueExtractor);

    final List<T> leftSide = [];
    final List<T> rightSide = [];

    // Algoritma Partition:
    // Elemen <= pivot ditempatkan di sisi kiri (left)
    // Elemen > pivot ditempatkan di sisi kanan (right)
    for (final item in items) {
      final value = valueExtractor(item);
      if (value <= pivot) {
        leftSide.add(item);
      } else {
        rightSide.add(item);
      }
    }

    return PartitionResult<T>(
      left: leftSide,
      right: rightSide,
      pivotValue: pivot,
      partitionedList: [...leftSide, ...rightSide],
    );
  }
}
