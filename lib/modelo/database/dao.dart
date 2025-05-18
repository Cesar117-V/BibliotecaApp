import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Dao {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('biblioteca.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, filePath);
    return await openDatabase(
      path,
      version: 7, // <-- Antes era 6, ahora 7
      onCreate: _createDB,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 7) {
          // Sólo corre una vez, la primera vez que abra versión 7
          await db.execute(
            'ALTER TABLE libros ADD COLUMN stock INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
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
        cantidad_libros INTEGER NOT NULL,
        numero_clasificador TEXT NOT NULL,
        trabajador TEXT NOT NULL,
        fecha_prestamo TEXT,
        fecha_devolucion TEXT NOT NULL,
        observaciones TEXT
      )
    """);
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
    final maps = await db.query('prestamos');
    return List.generate(maps.length, (i) => Prestamo.fromJson(maps[i]));
  }
}
