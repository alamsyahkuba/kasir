import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;

  String formatRupiah(num number) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final response = await supabase
        .from('transactions')
        .select(
            'id, date, total_price, customers(name), detail_transactions(product_id, product_qty, sub_total, products(name))')
        .order('date', ascending: false);

    return response;
  }

  void _showDeleteConfirmationDialog(int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus Riwayat Transaksi"),
          content: Text(
            "Anda yakin ingin menghapus riwayat transaksi ini? Transaksi ini tidak dapat dipulihkan.",
          ),
          actions: [
            // Tombol Batal
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            // Tombol Hapus
            TextButton(
              onPressed: () {
                // Panggil fungsi untuk menghapus transaksi
                _deleteTransaction(transactionId);
                Navigator.of(context).pop(); // Menutup dialog setelah menghapus
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(int transactionId) async {
    try {
      // Hapus data di tabel detail_transactions terlebih dahulu
      final detailResponse = await supabase
          .from('detail_transactions')
          .delete()
          .eq('transaction_id', transactionId);

      if (detailResponse != null) {
        throw Exception(
            'Gagal menghapus detail transaksi: ${detailResponse.error!.message}');
      }

      // Setelah detail transaksi dihapus, hapus transaksi di tabel transactions
      final transactionResponse =
          await supabase.from('transactions').delete().eq('id', transactionId);

      if (transactionResponse != null) {
        throw Exception(
            'Gagal menghapus transaksi: ${transactionResponse.error!.message}');
      }

      // Jika berhasil, tampilkan snackbar dan perbarui tampilan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaksi berhasil dihapus!")),
      );
      setState(() {}); // Untuk memperbarui tampilan setelah dihapus
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus transaksi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }

          final transactions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final customerName = transaction['customers']['name'] ?? "Umum";
              final date = formatDate(transaction['date']);
              final total = formatRupiah(transaction['total_price']);
              final details = transaction['detail_transactions'];
              final transactionNumber =
                  transactions.length - index; // Riwayat #X

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🧾 Riwayat #$transactionNumber",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text("$date - $customerName",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  subtitle: Text("Total: $total",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: List.generate(details.length, (i) {
                            final detail = details[i];
                            return ListTile(
                              title: Text(detail['products']['name'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                "Qty: ${detail['product_qty']}  -  Subtotal: ${formatRupiah(detail['sub_total'])}",
                              ),
                            );
                          }),
                        )),
                    // Tombol Hapus
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showDeleteConfirmationDialog(transaction['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          minimumSize: Size(double.infinity, 45),
                        ),
                        child: Text(
                          "Hapus Transaksi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
