import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  List<ExpenseModel> allExpenses = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final txData = await StorageService.getTransactions();
    final exData = await StorageService.getExpenses();
    setState(() {
      allTransactions = txData.reversed.toList();
      allExpenses = exData;
      filteredTransactions = allTransactions;
    });
  }

  void _filterByDate() {
    if (startDate != null && endDate != null) {
      setState(() {
        filteredTransactions = allTransactions.where((tx) {
          DateTime txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          return (txDate.isAtSameMomentAs(startDate!) || txDate.isAfter(startDate!)) &&
                 (txDate.isAtSameMomentAs(endDate!) || txDate.isBefore(endDate!));
        }).toList();
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _filterByDate();
    }
  }

  Future<void> _printReceipt(TransactionModel tx) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("STRUK PENJUALAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Divider(),
              pw.Text("ID: ${tx.id}"),
              pw.Text("Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(tx.date)}"),
              pw.Divider(),
              pw.ListView.builder(
                itemCount: tx.items.length,
                itemBuilder: (context, index) {
                  final item = tx.items[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${item['name']} x${item['qty']}"),
                        pw.Text("Rp ${(item['price'] * item['qty']).toStringAsFixed(0)}"),
                      ],
                    ),
                  );
                },
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rp ${tx.total.toStringAsFixed(0)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    double totalSales = filteredTransactions.fold(0, (sum, item) => sum + item.total);
    return Scaffold(
      appBar: AppBar(
        title: const Text("LAPORAN PENJUALAN"),
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: () => _selectDateRange(context)),
          if (startDate != null) IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue,
            width: double.infinity,
            child: Column(
              children: [
                const Text("Total Omzet Periode Ini", style: TextStyle(color: Colors.white70)),
                Text("Rp ${totalSales.toStringAsFixed(0)}", 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, i) {
                final tx = filteredTransactions[i];
                return ListTile(
                  title: Text("ID: ${tx.id}"),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
                  trailing: Text("Rp ${tx.total.toStringAsFixed(0)}"),
                  onTap: () => _showDetail(tx),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detail Transaksi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tx.items.map((e) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("${e['name']} x${e['qty']}"), Text("Rp ${e['price'] * e['qty']}")],
          )).toList(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: () => _printReceipt(tx)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("TUTUP")),
        ],
      ),
    );
  }
}