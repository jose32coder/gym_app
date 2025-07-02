import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClienteHomePage extends StatelessWidget {
  final User user;

  const ClienteHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Cliente'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              user.displayName ?? 'Cliente',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              user.email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Mis Rutinas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aquí navegas a la pantalla de rutinas del cliente
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Mis Reservas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aquí navegas a la pantalla de reservas
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Pagos y Membresías'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aquí navegas a la pantalla de pagos
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Soporte'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aquí navegas a la pantalla de soporte
            },
          ),
        ],
      ),
    );
  }
}
