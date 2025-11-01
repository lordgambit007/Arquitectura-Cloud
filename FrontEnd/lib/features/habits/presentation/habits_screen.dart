// lib/features/habits/presentation/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';
import 'package:flutteractixapp/features/habits/data/employees_api.dart';
import 'package:flutteractixapp/features/email/data/email_api.dart'; // ← NUEVO
import 'package:go_router/go_router.dart';

/// Mantiene el nombre HabitsScreen, pero muestra EMPLEADOS.
/// Verifica token: si no hay, pide iniciar sesión.
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  EmployeesApi? api;
  Future<List<Map<String, dynamic>>>? futureList;

  bool _initializing = true;
  bool _needsLogin = false;
  String perfMsg = '';

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  Future<void> _initApi() async {
    try {
      // Usa la MISMA clave que el resto de la app: BASE_URL
      final raw = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000';
      final normalized = raw.replaceAll(RegExp(r'/+$'), '');
      final baseUrl = normalized.endsWith('/api') ? normalized : '$normalized/api';

      // Revisa si hay token
      final token = await TokenStorage().getAccessToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _needsLogin = true;
          _initializing = false;
        });
        return;
      }

      // Crea EmployeesApi (ya no agregues /api)
      api = EmployeesApi(
        baseUrl: baseUrl,
        tokenStorage: TokenStorage(),
      );

      setState(() {
        futureList = api!.list();
        _initializing = false;
      });
    } catch (_) {
      setState(() {
        _needsLogin = true;
        _initializing = false;
      });
    }
  }

  void _reload() {
    if (api == null) return;
    setState(() {
      futureList = api!.list();
    });
  }

  Future<void> _deleteEmployee(dynamic id) async {
    if (api == null) return;
    try {
      await api!.delete(id.toString());
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _toggleRole(Map<String, dynamic> e) async {
    if (api == null) return;
    try {
      final currentRole = (e['role'] as String?) ?? '';
      final newRole = currentRole.contains('Senior') ? 'QA' : 'QA Senior';
      await api!.update(e['id'].toString(), {'role': newRole});
      if (!mounted) return;
      _reload();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $err')),
      );
    }
  }

  Future<void> _createEmployee() async {
    if (api == null) return;

    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final avatarCtrl =
        TextEditingController(text: 'https://i.pravatar.cc/150?img=3');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo empleado'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Rol')),
          TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: avatarCtrl,
              decoration: const InputDecoration(labelText: 'Avatar URL')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Crear')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api!.create({
          'name': nameCtrl.text,
          'role': roleCtrl.text,
          'email': emailCtrl.text.isEmpty ? null : emailCtrl.text,
          'salary': 0,
          'avatar_url': avatarCtrl.text.isEmpty ? null : avatarCtrl.text,
        });
        if (!mounted) return;
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo crear: $e')),
        );
      }
    }
  }

  /// ✏️ Editar empleado existente
  Future<void> _editEmployee(Map<String, dynamic> employee) async {
    if (api == null) return;

    final nameCtrl = TextEditingController(text: employee['name'] ?? '');
    final roleCtrl = TextEditingController(text: employee['role'] ?? '');
    final emailCtrl = TextEditingController(text: employee['email'] ?? '');
    final avatarCtrl =
        TextEditingController(text: employee['avatar_url'] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar empleado'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Rol')),
          TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: avatarCtrl,
              decoration: const InputDecoration(labelText: 'Avatar URL')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api!.update(employee['id'].toString(), {
          'name': nameCtrl.text,
          'role': roleCtrl.text,
          'email': emailCtrl.text.isEmpty ? null : emailCtrl.text,
          'avatar_url': avatarCtrl.text.isEmpty ? null : avatarCtrl.text,
        });
        if (!mounted) return;
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar: $e')),
        );
      }
    }
  }

  /// Modal para enviar correo → POST BFF /notify/email
  Future<void> _openEmailModal() async {
    final toCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool sending = false;
    String? error;

    await showDialog<void>(
      context: context,
      barrierDismissible: !sending,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) => AlertDialog(
            title: const Text('Enviar correo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: toCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Para (correo)',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Asunto'),
                ),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 4,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: sending ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: sending
                    ? null
                    : () async {
                        final to = toCtrl.text.trim();
                        final subject = subjectCtrl.text.trim();
                        final body = bodyCtrl.text.trim();

                        if (to.isEmpty || subject.isEmpty || body.isEmpty) {
                          setSt(() => error = 'Completa todos los campos');
                          return;
                        }

                        setSt(() {
                          sending = true;
                          error = null;
                        });

                        try {
                          await EmailApi().sendEmail(
                            to: to,
                            subject: subject,
                            body: body,
                          );
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Correo enviado (vía BFF → SNS)'),
                            ),
                          );
                        } catch (e) {
                          setSt(() {
                            sending = false;
                            error = 'No se pudo enviar: $e';
                          });
                        }
                      },
                icon: sending
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: const Text('Enviar'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bench simple: secuencial vs paralelo para imágenes
  Future<void> _measureSequentialVsParallel() async {
    if (api == null || !mounted) return;
    try {
      final sw1 = Stopwatch()..start();
      final list1 = await api!.list();
      for (final e in list1) {
        final u = e['avatar_url'];
        if (u != null && u.toString().isNotEmpty) {
          await http.get(Uri.parse(u.toString()));
        }
      }
      sw1.stop();

      final sw2 = Stopwatch()..start();
      final list2 = await api!.list();
      await Future.wait(list2.map((e) async {
        final u = e['avatar_url'];
        if (u != null && u.toString().isNotEmpty) {
          await http.get(Uri.parse(u.toString()));
        }
      }));
      sw2.stop();

      if (!mounted) return;
      setState(() {
        perfMsg =
            'Secuencial: ${sw1.elapsedMilliseconds} ms | Paralelo: ${sw2.elapsedMilliseconds} ms';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(perfMsg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error midiendo rendimiento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Empleados')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_needsLogin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Empleados')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56),
              const SizedBox(height: 12),
              const Text('Inicia sesión para ver empleados'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Ir a Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton( // ← NUEVO: botón para abrir modal de correo
            onPressed: _openEmailModal,
            icon: const Icon(Icons.email),
            tooltip: 'Enviar correo',
          ),
          IconButton(
              onPressed: _measureSequentialVsParallel,
              icon: const Icon(Icons.speed)),
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureList,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Sin empleados'));

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = items[i];
              return ListTile(
                leading: (e['avatar_url'] != null &&
                        (e['avatar_url'] as String).isNotEmpty)
                    ? CircleAvatar(backgroundImage: NetworkImage(e['avatar_url']))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(e['name'] ?? ''),
                subtitle: Text('${e['role'] ?? ''} • ${e['email'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editEmployee(e),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEmployee(e['id']),
                    ),
                  ],
                ),
                onTap: () => _toggleRole(e),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEmployee,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: perfMsg.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(perfMsg, textAlign: TextAlign.center),
            ),
    );
  }
}
