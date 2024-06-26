import 'package:flutter/material.dart';
import 'package:sintomas/controllers/sintoma_controller.dart';
import 'package:sintomas/models/sintoma.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sintomas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SintomaListPage(),
    );
  }
}

class SintomaListPage extends StatefulWidget {
  const SintomaListPage({super.key});

  @override
  _SintomaListPageState createState() => _SintomaListPageState();
}

class _SintomaListPageState extends State<SintomaListPage> {
  final SintomaController sintomaController = SintomaController();
  late Future<List<Sintoma>> _listaSintomas;

  @override
  void initState() {
    super.initState();
    _listaSintomas = sintomaController.getItems();
  }

  void _refreshList() {
    setState(() {
      _listaSintomas = sintomaController.getItems();
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateTime.parse(controller.text);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showForm([Sintoma? item]) {
    final formKey = GlobalKey<FormState>();
    String sintoma = item?.sintoma ?? '';
    int intensidade = item?.intensidade ?? 0;
    TextEditingController dataController =
        TextEditingController(text: item?.data ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: sintoma,
                  decoration: const InputDecoration(labelText: 'Sintoma'),
                  onSaved: (value) => sintoma = value!,
                ),
                TextFormField(
                  initialValue: intensidade.toString(),
                  decoration: const InputDecoration(labelText: 'Intensidade'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => intensidade = int.parse(value!),
                ),
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(labelText: 'Data'),
                  readOnly: true,
                  onTap: () => _selectDate(context, dataController),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newItem = Sintoma(
                    id: item?.id,
                    sintoma: sintoma,
                    intensidade: intensidade,
                    data: dataController.text,
                  );
                  if (item == null) {
                    sintomaController
                        .addItem(newItem)
                        .then((_) => _refreshList());
                  } else {
                    sintomaController
                        .updateItem(newItem)
                        .then((_) => _refreshList());
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String id) {
    sintomaController.deleteItem(id).then((_) {
      _refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item excluído com sucesso')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Sintoma App',
            style: TextStyle(
              color: Colors.white, // Cor do texto
              fontWeight: FontWeight.bold, // Negrito
              fontSize: 20.0, // Tamanho da fonte
            ),
          ),
        ),
        backgroundColor: Colors.blue, // Cor de fundo da barra superior
      ),
      body: FutureBuilder<List<Sintoma>>(
        future: _listaSintomas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sem items'));
          }
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.sintoma),
                    Text(
                      item.data,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                subtitle: Text('Intensidade: ${item.intensidade}'),
                onLongPress: () => _showForm(item),
                onTap: () => _showForm(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(item.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
