import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

final db = FirebaseFirestore.instance;

class Vendeuse {
  String id;
  String nom;
  String numeroDeTelephone;
  double longitude;
  double latitude;
  String adresse;
  String localite;
  String photo;
  String lundi;
  String mardi;
  String mercredi;
  String jeudi;
  String vendredi;
  String samedi;
  String dimanche;
  Vendeuse(
      String nom,
      String numeroDeTelephone,
      double longitude,
      double latitude,
      String adresse,
      String localite,
      String lundi,
      String mardi,
      String mercredi,
      String jeudi,
      String vendredi,
      String samedi,
      String dimanche) {
    this.nom = nom;
    this.numeroDeTelephone = numeroDeTelephone;
    this.longitude = longitude;
    this.latitude = latitude;
    this.adresse = adresse;
    this.localite = localite;
    this.lundi = lundi;
    this.mardi = mardi;
    this.mercredi = mercredi;
    this.jeudi = jeudi;
    this.vendredi = vendredi;
    this.samedi = vendredi;
    this.dimanche = dimanche;
  }

  static intialiseFireBaseApp() async {
    await Firebase.initializeApp();
  }

/*get*/
  static Future<List> recupererVendeuses() async {
    intialiseFireBaseApp();
    List vendeuses = [];
    await FirebaseFirestore.instance
        .collection('vendeuses')
        .orderBy('nom')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        vendeuses.add(doc);
      });
    });

    for (int i = 0; i < vendeuses.length; i++) {
      Vendeuse vendeuse = new Vendeuse(
          vendeuses[i]['nom'],
          vendeuses[i]['numeroDeTelephone'],
          vendeuses[i]['longitude'],
          vendeuses[i]['latitude'],
          vendeuses[i]['adresse'],
          vendeuses[i]['localite'],
          vendeuses[i]['lundi'],
          vendeuses[i]['mardi'],
          vendeuses[i]['mercredi'],
          vendeuses[i]['jeudi'],
          vendeuses[i]['vendredi'],
          vendeuses[i]['samedi'],
          vendeuses[i]['dimanche']);
      vendeuse.id = vendeuses[i].id;
      vendeuse.photo = vendeuses[i]['photo'];
      vendeuses[i] = vendeuse;
    }
    return vendeuses;
  }

  Future<QuerySnapshot> testAjout() async {
    intialiseFireBaseApp();
    return await FirebaseFirestore.instance
        .collection('vendeuses')
        .where('numeroDeTelephone', isEqualTo: this.numeroDeTelephone)
        .get();
  }

/*create*/
  Future ajoutVendeuse() async {
    intialiseFireBaseApp();
    await FirebaseFirestore.instance.collection('vendeuses').add({
      'nom': this.nom,
      'numeroDeTelephone': this.numeroDeTelephone,
      'longitude': this.longitude,
      'latitude': this.latitude,
      'adresse': this.adresse,
      'localite': this.localite,
      'photo': this.photo,
      'lundi': this.lundi,
      'mardi': this.mardi,
      'mercredi': this.mercredi,
      'jeudi': this.jeudi,
      'vendredi': this.vendredi,
      'samedi': this.samedi,
      'dimanche': this.dimanche
    }).then((value) {
      id = value.id.toString();
    }).catchError((error) {
      error.toString();
    });
  }

  Future<String> ajoutImage(File image) async {
    intialiseFireBaseApp();
    // String newName = path.join(path.dirname(image.path),'${this.numeroDeTelephone}.${path.extension(image.path)}');
    var storageRef = FirebaseStorage.instance.ref().child(
        '/photosVendeuses/${this.numeroDeTelephone}${path.extension(image.path)}/');
    await storageRef.putFile(image).whenComplete(() => storageRef
        .getDownloadURL()
        .then((url) => this.photo = url)
        .then((value) => print('photo uploaded')));
  }

/*delete*/
  Future suppImage() async {
    intialiseFireBaseApp();
    var storageRef = FirebaseStorage.instance.refFromURL(this.photo);
    try {
      await storageRef.delete();
      this.photo = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<DocumentSnapshot> supprimerVendeuse() async {
    intialiseFireBaseApp();
    await FirebaseFirestore.instance
        .collection('vendeuses')
        .doc(this.id)
        .delete();
    return await FirebaseFirestore.instance
        .collection('vendeuses')
        .doc(this.id)
        .get();
  }

/*update*/
  Future modifierVendeuse() async {
    intialiseFireBaseApp();
    await FirebaseFirestore.instance
        .collection('vendeuses')
        .doc(this.id)
        .set({
          'nom': this.nom,
          'numeroDeTelephone': this.numeroDeTelephone,
          'longitude': this.longitude,
          'latitude': this.latitude,
          'adresse': this.adresse,
          'localite': this.localite,
          'photo': this.photo,
          'lundi': this.lundi,
          'mardi': this.mardi,
          'mercredi': this.mercredi,
          'jeudi': this.jeudi,
          'vendredi': this.vendredi,
          'samedi': this.samedi,
          'dimanche': this.dimanche
        })
        .then((value) => print("Vendeuse modifiée"))
        .catchError((error) => print("Erreur: $error"));
  }
}
