import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../model/categoria_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CategoriaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'categoria/listar';

  Future<List<CategoriaModel>> listar(dynamic idUrbe) async {
    List<CategoriaModel> categoriasResponse = [];
    try {
      await FirebaseFirestore.instance.collection("category").get().then((categorys){
        if(categorys.size>0){
          categorys.docs.forEach((category) { 
            CategoriaModel categoriaModel = CategoriaModel();
            Map categoryModel = category.data();
            categoriaModel.idCategoria = categoryModel['id_categoria'];
            categoriaModel.estado = 1; 
            categoriaModel.label = categoryModel['categoria']; 
            categoriaModel.nombre = categoryModel['categoria'];
            categoriaModel.img = categoryModel['img'];
            categoriasResponse.add(categoriaModel);
          });
        }
      });
      return categoriasResponse;
    } catch (err) {
      return categoriasResponse;
    } 
  }
}