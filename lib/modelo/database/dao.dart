import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/bibliotecario.dart';
import 'package:biblioteca_app/modelo/trabajador.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:biblioteca_app/modelo/devolucion.dart';
import 'package:biblioteca_app/modelo/detalleprestamo.dart';
import 'package:flutter/foundation.dart';

class Dao {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('biblioteca.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final databasePath = await databaseFactory.getDatabasesPath();
    final path = join(databasePath, filePath);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: _createDB,
        onUpgrade: (db, oldV, newV) async {
          if (oldV < 7) {
            await db.execute(
              'ALTER TABLE libros ADD COLUMN stock INTEGER NOT NULL DEFAULT 0',
            );
          }
        },
      ),
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE autores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        correo TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE libros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        imagen TEXT NOT NULL,
        id_categoria INTEGER NOT NULL,
        numero_paginas INTEGER NOT NULL,
        id_autor INTEGER NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        num_adquisicion TEXT NOT NULL,
        cantidad_ejemplares INTEGER NOT NULL,
        disponible INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_categoria) REFERENCES categorias (id),
        FOREIGN KEY (id_autor) REFERENCES autores (id)
      )
    """);

    await db.execute("""
      CREATE TABLE prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        matricula TEXT NOT NULL,
        nombre_solicitante TEXT NOT NULL,
        carrera TEXT NOT NULL,
        sexo TEXT NOT NULL,
        cantidad_libros INTEGER NOT NULL,
        numero_clasificador TEXT NOT NULL,
        trabajador TEXT NOT NULL,
        fecha_prestamo TEXT,
        fecha_devolucion TEXT NOT NULL,
        observaciones TEXT,
        activo INTEGER NOT NULL DEFAULT 1       
      )
    """);

    await db.execute("""
      CREATE TABLE detalleprestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_prestamo INTEGER NOT NULL,
        id_libro INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        no_adquisicion TEXT NOT NULL,
        categoria TEXT NOT NULL,
        autor TEXT NOT NULL,
        FOREIGN KEY (id_prestamo) REFERENCES prestamos (id),
        FOREIGN KEY (id_libro) REFERENCES libros (id)
      )
    """);

    await db.execute("""
      CREATE TABLE devoluciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_prestamo INTEGER NOT NULL,
        fecha_EntregaReal TEXT NOT NULL,
        estado_libro TEXT,
        responsable_devolucion TEXT NOT NULL,
        observaciones TEXT,
        FOREIGN KEY (id_prestamo) REFERENCES prestamos (id)
      )
    """);

    await db.execute("""
      CREATE TABLE bibliotecarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        matricula TEXT NOT NULL,
        carrera TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        codigo TEXT NOT NULL
      )
""");

    await db.execute("""
      CREATE TABLE historial_prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_prestamo INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        no_adquisicion TEXT NOT NULL,
        categoria TEXT NOT NULL,
        autor TEXT NOT NULL,
        fecha_devolucion TEXT NOT NULL,
        nombre_solicitante TEXT NOT NULL,
        matricula TEXT NOT NULL
      )
    """);

    await db.execute('''
  CREATE TABLE IF NOT EXISTS trabajadores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT,
    apellidos TEXT,
    correo TEXT,
    codigo TEXT
  )
''');
  }

  // --------------------- AUTORES ---------------------
  static Future<Autor> createAutor(Autor autor) async {
    final db = await database;
    final id = await db.insert('autores', autor.toJson());
    print("✅ [DAO] autor insertado con id=$id");
    autor.id = id;
    return autor;
  }

  static Future<List<Autor>> getAllAutores() async {
    final db = await database;
    final maps = await db.query('autores');
    return List.generate(maps.length, (i) => Autor.fromJson(maps[i]));
  }

  static Future<int> updateAutor(Autor autor) async {
    final db = await database;
    return await db.update(
      'autores',
      autor.toJson(),
      where: 'id = ?',
      whereArgs: [autor.id],
    );
  }

  static Future<int> deleteAutor(int id) async {
    final db = await database;
    return await db.delete('autores', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Autor>> listaAutores() async {
    final db = await database;
    final maps = await db.query('autores');
    final lista = List.generate(maps.length, (i) => Autor.fromJson(maps[i]));
    print("🔍 [DAO] listaAutores encontró ${lista.length} registros");
    return lista;
  }

  static Future<List<Libro>> obtenerLibrosPorAutor(int idAutor) async {
    final db = await database;
    final maps = await db.query(
      'libros',
      where: 'id_autor = ?',
      whereArgs: [idAutor],
    );
    return List.generate(maps.length, (i) => Libro.fromJson(maps[i]));
  }

  // --------------------- CATEGORÍAS ---------------------
  static Future<Categoria> createCategoria(Categoria categoria) async {
    final db = await database;
    final id = await db.insert('categorias', categoria.toJson());
    categoria.id = id;
    return categoria;
  }

  static Future<int> updateCategoria(Categoria categoria) async {
    final db = await database;
    return await db.update(
      'categorias',
      categoria.toJson(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  static Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Categoria>> listaCategorias() async {
    final db = await database;
    final maps = await db.query('categorias');
    return List.generate(maps.length, (i) => Categoria.fromJson(maps[i]));
  }

  // --------------------- LIBROS ---------------------
  static Future<Libro> createLibro(Libro libro) async {
    final db = await database;
    final id = await db.insert('libros', libro.toJson());
    libro.id = id;
    return libro;
  }

  static Future<int> updateLibro(Libro libro) async {
    final db = await database;
    return await db.update(
      'libros',
      libro.toJson(),
      where: 'id = ?',
      whereArgs: [libro.id],
    );
  }

  static Future<int> deleteLibro(int id) async {
    final db = await database;
    return await db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Libro>> listaLibros() async {
    final db = await database;
    final maps = await db.query('libros');
    return List.generate(maps.length, (i) => Libro.fromJson(maps[i]));
  }

  static Future<List<Libro>> listaLibrosPorCategoria({int? idCategoria}) async {
    final db = await database;
    final where = idCategoria != null ? 'id_categoria = ?' : null;
    final whereArgs = idCategoria != null ? [idCategoria] : null;
    final maps = await db.query(
      'libros',
      where: where,
      whereArgs: whereArgs,
    );
    return List.generate(maps.length, (i) => Libro.fromJson(maps[i]));
  }

  static Future<List<Libro>> obtenerLibrosDisponibles() async {
    final db = await database;

    // 1. Obtener todos los libros
    final librosTotales = await db.query('libros');

    // 2. Obtener conteo de ejemplares prestados por id_libro
    final prestamos = await db.rawQuery('''
      SELECT id_libro, COUNT(*) as cantidad
      FROM detalleprestamos dp
      JOIN prestamos p ON p.id = dp.id_prestamo
      GROUP BY id_libro
    ''');

    // 3. Mapear los libros prestados
    final Map<int, int> enPrestamo = {
      for (var p in prestamos) p['id_libro'] as int: p['cantidad'] as int
    };

    // 4. Filtrar libros con ejemplares disponibles
    final disponibles = <Libro>[];

    for (var json in librosTotales) {
      final libro = Libro.fromJson(json);
      final prestados = enPrestamo[libro.id] ?? 0;

      final disponiblesStock = (libro.stock ?? 0) - prestados;

      if (disponiblesStock > 0) {
        libro.stock = disponiblesStock;
        disponibles.add(libro);
      }
    }

    return disponibles;
  }

  static Future<List<Libro>> obtenerEjemplaresDisponiblesPorTitulo(
      String titulo) async {
    final db = await database;
    final maps = await db.query(
      'libros',
      where: 'titulo = ? AND disponible = 1',
      whereArgs: [titulo],
    );
    return List.generate(maps.length, (i) => Libro.fromJson(maps[i]));
  }

  static Future<void> actualizarTituloGrupo(
      String tituloOriginal, String nuevoTitulo) async {
    final db = await database;
    await db.update(
      'libros',
      {'titulo': nuevoTitulo},
      where: 'titulo = ?',
      whereArgs: [tituloOriginal],
    );
  }

  static Future<void> actualizarGrupoDeLibros({
    required String tituloOriginal,
    String? nuevoTitulo,
    String? descripcion,
    int? idCategoria,
    int? idAutor,
    String? imagen,
  }) async {
    final db = await database;
    final data = <String, Object?>{};

    if (nuevoTitulo != null) data['titulo'] = nuevoTitulo;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (idCategoria != null) data['id_categoria'] = idCategoria;
    if (idAutor != null) data['id_autor'] = idAutor;
    if (imagen != null) data['imagen'] = imagen;

    if (data.isEmpty) return;

    await db.update(
      'libros',
      data,
      where: 'titulo = ?',
      whereArgs: [tituloOriginal],
    );
  }

  // --------------------- PRÉSTAMOS ---------------------
  static Future<Prestamo> createPrestamo(Prestamo prestamo) async {
    final db = await database;
    final id = await db.insert('prestamos', prestamo.toJson());
    prestamo.id = id;
    return prestamo;
  }

  static Future<int> updatePrestamo(Prestamo prestamo) async {
    final db = await database;
    return await db.update(
      'prestamos',
      prestamo.toJson(),
      where: 'id = ?',
      whereArgs: [prestamo.id],
    );
  }

  static Future<int> deletePrestamo(int id) async {
    final db = await database;
    return await db.delete('prestamos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Prestamo>> listaPrestamos() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT p.*,
        GROUP_CONCAT(dp.titulo, ', ') AS titulo_libro
      FROM prestamos p
      LEFT JOIN detalleprestamos dp ON dp.id_prestamo = p.id
      GROUP BY p.id
    ''');

    return List.generate(result.length, (i) => Prestamo.fromJson(result[i]));
  }

  static Future<List<Prestamo>> obtenerPrestamosActivos() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT p.*,
            GROUP_CONCAT(dp.titulo, ', ') AS titulo_libro
      FROM prestamos p
      LEFT JOIN detalleprestamos dp ON dp.id_prestamo = p.id
      WHERE p.activo = 1
      GROUP BY p.id
    ''');
    return List.generate(result.length, (i) => Prestamo.fromJson(result[i]));
  }

  static Future<void> restaurarStockPorPrestamo(int idPrestamo) async {
    final db = await database;

    final detalles = await db.rawQuery('''
      SELECT id_libro, COUNT(*) as cantidad
      FROM detalleprestamos
      WHERE id_prestamo = ?
      GROUP BY id_libro
    ''', [idPrestamo]);

    for (var detalle in detalles) {
      final idLibro = detalle['id_libro'] as int;
      final cantidad = detalle['cantidad'] as int;

      await db.rawUpdate('''
        UPDATE libros
        SET stock = 
          CASE 
            WHEN stock + ? > cantidad_ejemplares THEN cantidad_ejemplares
            ELSE stock + ?
          END,
          disponible = 1
        WHERE id = ?
      ''', [cantidad, cantidad, idLibro]);
    }
  }

  // --------------------- DETALLE DE PRÉSTAMOS ---------------------

  static Future<DetallePrestamo> createDetallePrestamo(
      DetallePrestamo d) async {
    final db = await database;

    final id = await db.insert('detalleprestamos', d.toJson());
    d.id = id;

    debugPrint("📚 Marcando como no disponible: idLibro=${d.idLibro}");

    final rows = await db.update(
      'libros',
      {'disponible': 0},
      where: 'id = ?',
      whereArgs: [d.idLibro],
    );

    debugPrint("🟡 Filas afectadas en libros: $rows");

    return d;
  }

  static Future<List<DetallePrestamo>> getDetallesPorPrestamo(
      int idPrestamo) async {
    final db = await database;
    final maps = await db.query(
      'detalleprestamos',
      where: 'id_prestamo = ?',
      whereArgs: [idPrestamo],
    );
    return List.generate(maps.length, (i) => DetallePrestamo.fromJson(maps[i]));
  }

  static Future<void> eliminarDetallePrestamoPorIdPrestamo(
      int idPrestamo) async {
    final db = await database;
    await db.delete(
      'detalleprestamos',
      where: 'id_prestamo = ?',
      whereArgs: [idPrestamo],
    );
  }

  // --------------------- DEVOLUCIONES ---------------------
  static Future<Devolucion> createDevolucion(Devolucion d) async {
    final db = await database;
    final id = await db.insert('devoluciones', d.toJson());
    d.id = id;
    return d;
  }

  static Future<int> updateDevolucion(Devolucion d) async {
    final db = await database;
    return await db.update(
      'devoluciones',
      d.toJson(),
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }

  static Future<int> deleteDevolucion(int id) async {
    final db = await database;
    return await db.delete('devoluciones', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Devolucion>> listaDevoluciones() async {
    final db = await database;
    final maps = await db.query('devoluciones');
    return List.generate(maps.length, (i) => Devolucion.fromJson(maps[i]));
  }

  static Future<void> liberarLibrosPorDevolucion(int idPrestamo) async {
    final db = await database;

    final detalles = await db.query(
      'detalleprestamos',
      where: 'id_prestamo = ?',
      whereArgs: [idPrestamo],
    );

    for (var detalle in detalles) {
      final idLibro = detalle['id_libro'] as int;

      // Restaurar stock al devolver
      await db.rawUpdate('''
        UPDATE libros
        SET stock = 
          CASE 
            WHEN stock + 1 > cantidad_ejemplares THEN cantidad_ejemplares 
            ELSE stock + 1 
          END
        WHERE id = ?
      ''', [idLibro]);

      // ⚠️ MARCAR COMO DISPONIBLE
      await db.update(
        'libros',
        {'disponible': 1},
        where: 'id = ?',
        whereArgs: [idLibro],
      );
    }
  }

  // --------------------- BIBLIOTECARIOS ---------------------

  // LISTA
  static Future<List<Bibliotecario>> listaBibliotecarios() async {
    final db = await database;
    final maps = await db.query('bibliotecarios');
    return List.generate(maps.length, (i) => Bibliotecario.fromJson(maps[i]));
  }

  // CREAR
  static Future<Bibliotecario> createBibliotecario(Bibliotecario b) async {
    final db = await database;
    final id = await db.insert('bibliotecarios', b.toJson());
    b.id = id;
    return b;
  }

  // ACTUALIZAR
  static Future<int> updateBibliotecario(Bibliotecario b) async {
    final db = await database;
    return await db.update(
      'bibliotecarios',
      b.toJson(),
      where: 'id = ?',
      whereArgs: [b.id],
    );
  }

  // ELIMINAR
  static Future<int> deleteBibliotecario(int id) async {
    final db = await database;
    return await db.delete('bibliotecarios', where: 'id = ?', whereArgs: [id]);
  }

  // Validar bibliotecario (para login)
  static Future<bool> validarBibliotecario(String correo, String codigo) async {
    final db = await database;
    final result = await db.query(
      'bibliotecarios',
      where: 'correo = ? AND codigo = ?',
      whereArgs: [correo, codigo],
    );
    return result.isNotEmpty;
  }

  // Obtener un bibliotecario por correo y código
  static Future<Bibliotecario?> obtenerBibliotecario(
      String correo, String codigo) async {
    final db = await database;
    final maps = await db.query(
      'bibliotecarios',
      where: 'correo = ? AND codigo = ?',
      whereArgs: [correo, codigo],
    );

    if (maps.isNotEmpty) {
      return Bibliotecario.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // --------------------- HISTORIAL DE PRÉSTAMOS ---------------------
  static Future<void> guardarHistorialPrestamo(
      int idPrestamo, String fechaDevolucion) async {
    final db = await database;

    try {
      // Obtener info del préstamo principal
      final prestamo = await db.query(
        'prestamos',
        where: 'id = ?',
        whereArgs: [idPrestamo],
        limit: 1,
      );

      if (prestamo.isEmpty) {
        debugPrint("❌ No se encontró el préstamo con ID $idPrestamo");
        return;
      }

      final nombreSolicitante =
          prestamo[0]['nombre_solicitante'] ?? 'Desconocido';
      final matricula = prestamo[0]['matricula'] ?? 'N/A';

      // Obtener los detalles del préstamo
      final detalles = await db.query(
        'detalleprestamos',
        where: 'id_prestamo = ?',
        whereArgs: [idPrestamo],
      );

      if (detalles.isEmpty) {
        debugPrint(
            "⚠️ No se encontraron detalles para el préstamo con ID $idPrestamo");
        return;
      }

      for (var d in detalles) {
        final titulo = d['titulo'];
        final noAdquisicion = d['no_adquisicion'];
        final categoria = d['categoria'];
        final autor = d['autor'];

        if ([titulo, noAdquisicion, categoria, autor].any((e) => e == null)) {
          debugPrint("⚠️ Datos incompletos: $d");
          continue;
        }

        final insertData = {
          'id_prestamo': idPrestamo,
          'titulo': titulo,
          'no_adquisicion': noAdquisicion,
          'categoria': categoria,
          'autor': autor,
          'fecha_devolucion': fechaDevolucion,
          'nombre_solicitante': nombreSolicitante,
          'matricula': matricula,
        };

        await db.insert('historial_prestamos', insertData);
        debugPrint("✅ Historial guardado: $insertData");
      }
    } catch (e) {
      debugPrint("❌ Error inesperado en guardarHistorialPrestamo: $e");
    }
  }

  static Future<void> updatePrestamoActivo(int idPrestamo, bool activo) async {
    final db = await database;
    await db.update(
      'prestamos',
      {'activo': activo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [idPrestamo],
    );
  }

  static Future<List<Map<String, dynamic>>>
      listaDevolucionesConPrestamo() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT d.*, 
           p.nombre_solicitante, 
           p.matricula,
           GROUP_CONCAT(l.titulo, ', ') as titulos_libros
    FROM devoluciones d
    JOIN prestamos p ON d.id_prestamo = p.id
    LEFT JOIN detalleprestamos dp ON dp.id_prestamo = p.id
    LEFT JOIN libros l ON l.id = dp.id_libro
    GROUP BY d.id
    ORDER BY d.id DESC
  ''');
  }

  static Future<List<Map<String, dynamic>>>
      obtenerHistorialPrestamosExtendido() async {
    final db = await database;
    return await db.rawQuery('''
   SELECT h.*, 
       p.trabajador AS nombre_trabajador, 
       d.estado_libro, 
       d.responsable_devolucion
FROM historial_prestamos h
LEFT JOIN prestamos p ON h.id_prestamo = p.id
LEFT JOIN devoluciones d ON h.id_prestamo = d.id_prestamo
ORDER BY h.fecha_devolucion DESC
  ''');
  }

<<<<<<< HEAD
  //-----------Obtner datos estadisticas de prestamos----------------

  static Future<List<Map<String, dynamic>>> prestamosPorTrimestreGeneroCarrera({
    required int year,
    required int trimestre, // 1, 2, 3, 4
  }) async {
    final db = await database;
    // Define los rangos de fechas para cada trimestre
    final fechas = [
      ['01-01', '03-31'],
      ['04-01', '06-30'],
      ['07-01', '09-30'],
      ['10-01', '12-31'],
    ];
    final inicio = "$year-${fechas[trimestre - 1][0]}";
    final fin = "$year-${fechas[trimestre - 1][1]}";

    return await db.rawQuery('''
    SELECT carrera, sexo, COUNT(*) as cantidad
    FROM prestamos
    WHERE fecha_prestamo BETWEEN ? AND ?
    GROUP BY carrera, sexo
    ORDER BY carrera, sexo
  ''', [inicio, fin]);
  }
//-----------Obtener lista de deudores de prestamos----------------

  static Future<List<Map<String, dynamic>>> obtenerDeudores() async {
    final db = await database;
    final hoy = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    return await db.rawQuery('''
    SELECT matricula, nombre_solicitante, carrera
    FROM prestamos
    WHERE activo = 1
      AND fecha_devolucion < ?
  ''', [hoy]);
=======
  // --------------------- TRABAJADORES ---------------------

// LISTA
  static Future<List<Trabajador>> listaTrabajadores() async {
    final db = await database;
    final maps = await db.query('trabajadores');
    return List.generate(maps.length, (i) => Trabajador.fromJson(maps[i]));
  }

// CREAR
  static Future<Trabajador> createTrabajador(Trabajador t) async {
    final db = await database;
    final id = await db.insert('trabajadores', t.toJson());
    t.id = id;
    return t;
  }

// ACTUALIZAR
  static Future<int> updateTrabajador(Trabajador t) async {
    final db = await database;
    return await db.update(
      'trabajadores',
      t.toJson(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

// ELIMINAR
  static Future<int> deleteTrabajador(int id) async {
    final db = await database;
    return await db.delete('trabajadores', where: 'id = ?', whereArgs: [id]);
  }

// Validar trabajador (para login)
  static Future<bool> validarTrabajador(String correo, String codigo) async {
    final db = await database;
    final result = await db.query(
      'trabajadores',
      where: 'correo = ? AND codigo = ?',
      whereArgs: [correo, codigo],
    );
    return result.isNotEmpty;
  }

// Obtener un trabajador por correo y código
  static Future<Trabajador?> obtenerTrabajador(
      String correo, String codigo) async {
    final db = await database;
    final maps = await db.query(
      'trabajadores',
      where: 'correo = ? AND codigo = ?',
      whereArgs: [correo, codigo],
    );

    if (maps.isNotEmpty) {
      return Trabajador.fromJson(maps.first);
    } else {
      return null;
    }
>>>>>>> feebb32 (Agregado diseño responsivo y funcionalidad de editar/eliminar trabajadores)
  }
}
