import 'package:flutter/material.dart';
import 'package:flutter_application_5/pages/user_management_page.dart';
import 'package:intl/intl.dart'; // Importa intl para el formato de fecha
import '../models/order.dart'; // Asegúrate de tener un modelo para Order
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de importar la página de inicio de sesión

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final List<Order> _orders = [];
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  Order? _editingOrder;
  bool _isFormVisible = false; // Controla la visibilidad del formulario

  final Map<String, int> _roleToIdMap = {
    'Admin': 1,
    'Chef': 2,
    'Mesero': 3,
  };

  final List<String> _menuTypes = ['Corriente', 'Ejecutivo', 'Especial'];
  final List<String> _tableIds =
      List.generate(10, (index) => 'Mesa ${index + 1}');
  final List<String> _userIds =
      List.generate(10, (index) => 'Mesero ${index + 1}');
  final List<String> _quantities =
      List.generate(20, (index) => (index + 1).toString());

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('HH:mm');

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedQuantity;
  String? _selectedMenuType;
  String? _selectedUserId;
  String? _selectedTableId;

  void _addOrder() {
    final date = _dateController.text;
    final time = _timeController.text;
    final quantity = int.tryParse(_selectedQuantity ?? '') ?? 0;
    final pricePerItem = double.tryParse(_totalPriceController.text) ?? 0.0;
    final totalPrice = quantity * pricePerItem;
    final menuType = _selectedMenuType ?? '';
    final userId = int.tryParse(_selectedUserId ?? '') ?? 0; // Usa tryParse
    final tableId = int.tryParse(_selectedTableId ?? '') ?? 0; // Usa tryParse

    if (date.isEmpty ||
        time.isEmpty ||
        quantity <= 0 ||
        pricePerItem <= 0 ||
        menuType.isEmpty ||
        userId <= 0 ||
        tableId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Por favor, completa todos los campos correctamente.'),
        ),
      );
      return;
    }

    setState(() {
      if (_editingOrder == null) {
        _orders.add(Order(
          id: 0, // Puedes usar un valor predeterminado o generar un ID si es necesario
          fecha: date,
          hora: time,
          totalPlatos: quantity,
          precioTotal: totalPrice,
          tipoMenu: menuType,
          idUsuarioFk: userId,
          idMesaFk: tableId,
          createAt: '', // Puedes asignar un valor predeterminado o calcularlo
          updateAt: '', // Puedes asignar un valor predeterminado o calcularlo
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comanda creada'),
          ),
        );
      } else {
        final index = _orders.indexOf(_editingOrder!);
        if (index != -1) {
          _orders[index] = Order(
            id: _editingOrder!.id,
            fecha: date,
            hora: time,
            totalPlatos: quantity,
            precioTotal: totalPrice,
            tipoMenu: menuType,
            idUsuarioFk: userId,
            idMesaFk: tableId,
            createAt: _editingOrder!.createAt,
            updateAt: _editingOrder!.updateAt,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Comanda actualizada'),
            ),
          );
        }
        _editingOrder = null;
      }

      //_clearFields();
    });
  }

  void _editOrder(Order order) {
    setState(() {
      _editingOrder = order;

      _dateController.text = order.fecha ?? '';
      _timeController.text = order.hora ?? '';
      _selectedQuantity = order.totalPlatos.toString();

      if (order.totalPlatos != 0) {
        _totalPriceController.text =
            (order.precioTotal! / order.totalPlatos!).toStringAsFixed(2);
      } else {
        _totalPriceController.text = '0.00';
      }

      _selectedMenuType = order.tipoMenu;
      _selectedUserId = order.idUsuarioFk.toString();
      _selectedTableId = order.idMesaFk.toString();
    });
  }

  void _deleteOrder(Order order) {
    setState(() {
      _orders.remove(order);
    });
  }

  void _clearFields() {
    _dateController.clear();
    _timeController.clear();
    _totalPriceController.clear();
    _quantityController.clear();
    _selectedQuantity = null;
    _selectedMenuType = null;
    _selectedUserId = null;
    _selectedTableId = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in'); // Elimina el estado de la sesión

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Elimina todas las pantallas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Comandas'),
        backgroundColor: const Color.fromARGB(255, 20, 42, 59),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(213, 108, 238, 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(0),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/img/platos.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 20, 42, 59),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/img/logo2.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 21, 128, 0),
                    ),
                    title: Text(
                      'Gestión de Usuarios',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 20, 42, 59),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Cierra el menú
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserManagementPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.assignment,
                      color: const Color.fromARGB(255, 21, 128, 0),
                    ),
                    title: Text(
                      'Gestión de Comandas',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 20, 42, 59),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Cierra el menú
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar el formulario solo si _isFormVisible es true
                if (_isFormVisible)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _selectDate(context),
                        readOnly: true,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _selectTime(context),
                        readOnly: true,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedQuantity,
                        items: _quantities.map((quantity) {
                          return DropdownMenuItem<String>(
                            value: quantity,
                            child: Text(quantity),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad de platos',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuantity = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedMenuType,
                        items: _menuTypes.map((menuType) {
                          return DropdownMenuItem<String>(
                            value: menuType,
                            child: Text(menuType),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Tipo de menú',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedMenuType = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedTableId,
                        items: _tableIds.map((tableId) {
                          return DropdownMenuItem<String>(
                            value: tableId,
                            child: Text(tableId),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'ID Mesa',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedTableId = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedUserId,
                        items: _userIds.map((userId) {
                          return DropdownMenuItem<String>(
                            value: userId,
                            child: Text(userId),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'ID Usuario',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _totalPriceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Precio unitario',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(214, 99, 219, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 12.0),
                        ),
                        child: Text(_editingOrder == null
                            ? 'Añadir Comanda'
                            : 'Actualizar Comanda'),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                // Título y línea verde
                Text(
                  'Comandas Creadas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.green,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                              'COMANDA ${index + 1}: \nFecha: ${order.fecha}, Hora: ${order.hora}'),
                          subtitle: Text(
                            'Cantidad: ${order.totalPlatos}, \n'
                            'Precio: \$${(order.precioTotal ?? 0.0).toStringAsFixed(2)}, \n'
                            'Menú: ${order.tipoMenu}, \n'
                            'Usuario: ${order.idUsuarioFk}, \n'
                            'Mesa: ${order.idMesaFk}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _editOrder(order),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.green),
                                onPressed: () => _deleteOrder(order),
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
          Positioned(
            bottom: 45.0, // Margen inferior
            right: 25.0, // Margen derecho
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFormVisible = !_isFormVisible; // Alternar visibilidad
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(214, 99, 219, 0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
              ),
              child: Text(_isFormVisible ? 'Ocultar Formulario' : 'ADD'),
            ),
          ),
        ],
      ),
    );
  }
}
