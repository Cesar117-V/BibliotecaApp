import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Dao {
  static Database? _database;

  // Obtener instancia de la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('biblioteca.db');
    return _database!;
  }

  // Inicializar la base de datos
  static Future<Database> _initDB(String filePath) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crear estructura de tablas
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
        nombre TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        imagen TEXT NOT NULL,
        id_categoria INTEGER NOT NULL,
        numero_paginas INTEGER NOT NULL,
        id_autor INTEGER NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES categorias (id),
        FOREIGN KEY (id_autor) REFERENCES autores (id)
      )
    """);
  }

  // Insertar autor
  static Future<Autor> createAutor(Autor autor) async {
    final db = await database;
    final id = await db.insert('autores', autor.toJson());
    autor.id = id;
    return autor;
  }

  // Obtener todos los autores
  static Future<List<Autor>> getAllAutores() async {
    final db = await database;
    final maps = await db.query('autores');
    return List.generate(maps.length, (i) => Autor.fromJson(maps[i]));
  }

  // Actualizar autor
  static Future<int> updateAutor(Autor autor) async {
    final db = await database;
    return await db.update(
      'autores',
      autor.toJson(),
      where: 'id = ?',
      whereArgs: [autor.id],
    );
  }

  // Eliminar autor
  static Future<int> deleteAutor(int id) async {
    final db = await database;
    return await db.delete('autores', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Autor>> listaAutores() async {
    final db = await database;
    final maps = await db.query('autores');
    return List.generate(maps.length, (i) => Autor.fromJson(maps[i]));
  }

  //Metodos para CRUD de categorias
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
    return db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Categoria>> listaCategorias() async {
    final db = await database;
    final maps = await db.query("categorias");
    return List.generate(maps.length, (i) => Categoria.fromJson(maps[i]));
  }

  //Metodos para CRUD de libro
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
    return db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Libro>> listaLibros() async {
    final db = await database;
    final maps = await db.query("libros");
    return List.generate(maps.length, (i) => Libro.fromJson(maps[i]));
  }
}