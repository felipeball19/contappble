import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userPassword;

  HomeScreen({required this.userPassword});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Ingreso> ingresos = [];
  List<Gasto> gastos = [];
  List<Ingreso> ingresosFiltrados = [];
  List<Gasto> gastosFiltrados = [];
  String searchQuery = '';

  double get totalIngresos => ingresosFiltrados.fold(0, (total, ingreso) => total + ingreso.total);
  double get totalGastos => gastosFiltrados.fold(0, (total, gasto) => total + gasto.total);

  @override
void initState() {
  super.initState();
  _loadUserData();
}

@override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userPassword != widget.userPassword) {
      _loadUserData();
    }
  }

  void _filtrarListas(String query) {
  setState(() {
    searchQuery = query.toLowerCase();
    ingresosFiltrados = ingresos
        .where((ingreso) => ingreso.nombre.toLowerCase().contains(searchQuery))
        .toList();
    gastosFiltrados = gastos
        .where((gasto) => gasto.nombre.toLowerCase().contains(searchQuery))
        .toList();
  });
}


  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ingresosData = prefs.getStringList('${widget.userPassword}_ingresos');
    List<String>? gastosData = prefs.getStringList('${widget.userPassword}_gastos');

    if (ingresosData != null) {
      setState(() {
        ingresos = ingresosData.map((e) => Ingreso.fromJson(e)).toList();
        ingresosFiltrados = ingresos;
      });
    }

    if (gastosData != null) {
      setState(() {
        gastos = gastosData.map((e) => Gasto.fromJson(e)).toList();
        gastosFiltrados = gastos;
      });
    }
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ingresosData = ingresos.map((e) => e.toJson()).toList();
    List<String> gastosData = gastos.map((e) => e.toJson()).toList();

    await prefs.setStringList('${widget.userPassword}_ingresos', ingresosData);
    await prefs.setStringList('${widget.userPassword}_gastos', gastosData);
  }

  void _logout() async {
  await _saveUserData(); // Guardar los datos del usuario antes de salir
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenido a tu nuevo entorno contable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filtrarListas,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _mostrarVentanaAgregar(context, 'Ingreso'),
              child: Text('Información de Ingresos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _mostrarVentanaAgregar(context, 'Gasto'),
              child: Text('Información de Gastos'),
            ),
            SizedBox(height: 20),
            Text(
              'Total de Ingresos: \$${totalIngresos.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total de Gastos: \$${totalGastos.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile('Ingresos', ingresosFiltrados),
                  _buildListTile('Gastos', gastosFiltrados),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarVentanaAgregar(BuildContext context, String tipo) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController totalController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar $tipo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nombreController,
                decoration: InputDecoration(hintText: 'Ingrese el nombre del $tipo'),
              ),
              TextField(
                controller: totalController,
                decoration: InputDecoration(hintText: 'Ingrese el total del $tipo'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty && totalController.text.isNotEmpty) {
                  setState(() {
                    double total = double.tryParse(totalController.text) ?? 0;
                    if (tipo == 'Ingreso') {
                      ingresos.add(Ingreso(
                        nombre: nombreController.text,
                        fecha: DateTime.now().toString(),
                        total: total,
                      ));
                      ingresosFiltrados = ingresos;
                    } else {
                      gastos.add(Gasto(
                        nombre: nombreController.text,
                        fecha: DateTime.now().toString(),
                        total: total,
                      ));
                      gastosFiltrados = gastos;
                    }
                  });
                  Navigator.of(context).pop();
                  _saveUserData();
                }
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListTile(String titulo, List<ItemFinanciero> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => ListTile(
          title: Text(item.nombre),
          subtitle: Text(item.fecha),
          trailing: Text(item.total.toStringAsFixed(2)),
        )).toList(),
      ],
    );
  }
}

class ItemFinanciero {
  final String nombre;
  final String fecha;
  final double total;

  ItemFinanciero({required this.nombre, required this.fecha, required this.total});

  String toJson() {
    return '{"nombre": "$nombre", "fecha": "$fecha", "total": $total}';
  }

  static ItemFinanciero fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return ItemFinanciero(
      nombre: data['nombre'],
      fecha: data['fecha'],
      total: data['total'].toDouble(),
    );
  }
}

class Ingreso extends ItemFinanciero {
  Ingreso({required String nombre, required String fecha, required double total})
      : super(nombre: nombre, fecha: fecha, total: total);

  @override
  String toJson() {
    return super.toJson();
  }

  static Ingreso fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Ingreso(
      nombre: data['nombre'],
      fecha: data['fecha'],
      total: data['total'].toDouble(),
    );
  }
}

class Gasto extends ItemFinanciero {
  Gasto({required String nombre, required String fecha, required double total})
      : super(nombre: nombre, fecha: fecha, total: total);

  @override
  String toJson() {
    return super.toJson();
  }

  static Gasto fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Gasto(
      nombre: data['nombre'],
      fecha: data['fecha'],
      total: data['total'].toDouble(),
    );
  }
}
