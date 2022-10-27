import 'dart:io';
import 'package:allocomaps/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:allocomaps/model/Vendeuse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class EcranAjout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Screen();
  }
}

class Screen extends State<EcranAjout> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Geolocator geolocator = Geolocator();
  File _image;
  Position _currentPosition;
  String adresse;
  String localite;
  bool located = false;
  bool loaded = false;
  RegExp horaire = new RegExp(r'^(\d\d|\d)H(\d\d|\d|)[-](\d\d|\d)H(\d\d|\d|)$',
      caseSensitive: false, multiLine: false, dotAll: false, unicode: false);
  RegExp contact = new RegExp(r'(\+\d{3}|)\d{10}$',
      caseSensitive: false, multiLine: false, dotAll: false, unicode: false);
  TextEditingController nom = new TextEditingController();
  TextEditingController tel = new TextEditingController();
  TextEditingController lundi = new TextEditingController();
  TextEditingController mardi = new TextEditingController();
  TextEditingController mercredi = new TextEditingController();
  TextEditingController jeudi = new TextEditingController();
  TextEditingController vendredi = new TextEditingController();
  TextEditingController samedi = new TextEditingController();
  TextEditingController dimanche = new TextEditingController();

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      final coordinates =
          new Coordinates(position.latitude, position.longitude);
      var addr = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      setState(() {
        var string = addr.first.addressLine.split(',');
        _currentPosition = position;
        adresse = string[0];
        localite = addr.first.locality;
        located = true;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget EnregistrementD() {
    return new AlertDialog(
        title: Text('Enregistrement', textAlign: TextAlign.center),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          ],
        ));
  }

  Widget SuccesD() {
    return new AlertDialog(
        title: Text('Vendeuse ajoutée', textAlign: TextAlign.center),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.orange, size: 50),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return Colors.orange;
                },
              )),
            ),
          ],
        ));
  }

  Widget ErrorD() {
    return new AlertDialog(
        title: Text('Erreur', textAlign: TextAlign.center),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Une erreur s\'est produite',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return Colors.red;
                },
              )),
            ),
          ],
        ),);
  }

  Widget PhotoDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Source', textAlign: TextAlign.center),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50.0,
                child: ElevatedButton(
                    onPressed: () async {
                      await ImagePicker.platform
                          .pickImage(source: ImageSource.camera)
                          .then((image) async {
                        File compressedFile =
                            await FlutterNativeImage.compressImage(
                          image.path,
                          quality: 5,
                        );
                        setState(() {
                          _image = File(compressedFile.path);
                          loaded = true;
                        });
                      });
                    },
                    style: ButtonStyle(backgroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Colors.orange;
                      },
                    )),
                    child: Row(
                      children: [
                        Text("Camera", style: TextStyle(color: Colors.white)),
                        Icon(Icons.camera, color: Colors.white)
                      ],
                    )),
              ),
              Container(
                height: 50.0,
                child: ElevatedButton(
                    onPressed: () async {
                      await ImagePicker.platform
                          .pickImage(source: ImageSource.gallery)
                          .then((image) async {
                        File compressedFile =
                            await FlutterNativeImage.compressImage(image.path,
                                quality: 5);
                        setState(() {
                          _image = File(compressedFile.path);
                          loaded = true;
                        });
                      });
                    },
                    style: ButtonStyle(backgroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Colors.orange;
                      },
                    )),
                    child: Row(
                      children: [
                        Text("Galerie", style: TextStyle(color: Colors.white)),
                        Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                        )
                      ],
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une vendeuse"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (builder) => Home())),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nom,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Veuillez renseigner le noms et les prénoms';
                  } else if (value.length < 3) {
                    return 'Le nom doit avoir au moins 3 caractères.';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Nom et prénoms*',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: tel,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  } else if (value.length < 3) {
                    return 'pas moins de 10 chiffres';
                  } else if (!contact.hasMatch(value)) {
                    return 'Veuillez entrer un contact conforme';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Numero de téléphone*',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: lundi,
                validator: (value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Lundi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: mardi,
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Mardi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: mercredi,
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Mercredi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: jeudi,
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Jeudi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: vendredi,
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Vendredi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: samedi,
                // ignore: missing_return
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Samedi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: dimanche,
                validator: (String value) {
                  if (value.isNotEmpty) {
                    if (!horaire.hasMatch(value)) {
                      return 'Veuillez entrer un horaire conforme (08H-12H)';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Horaire de vente Dimanche',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(05.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: loaded,
                        child: Container(
                          height: 50.0,
                          width: 100.0,
                          child: ElevatedButton(
                            onPressed: () => null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo),
                                Icon(Icons.check),
                              ],
                            ),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return Colors.orange;
                              },
                            )),
                          ),
                        ),
                        replacement: Container(
                          height: 50.0,
                          width: 100.0,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    PhotoDialog(context),
                              );
                            },
                            child: Icon(Icons.add_a_photo),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return Colors.orange;
                              },
                            )),
                          ),
                        ),
                        // color: Colors.amber)
                      ),
                      Visibility(
                        visible: located,
                        child: Container(
                          height: 50.0,
                          width: 100.0,
                          child: ElevatedButton(
                            onPressed: () => _getCurrentLocation(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_pin),
                                Icon(Icons.check),
                              ],
                            ),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return Colors.orange;
                              },
                            )),
                          ),
                        ),
                        replacement: Container(
                          height: 50.0,
                          width: 100.0,
                          child: ElevatedButton(
                            onPressed: () => _getCurrentLocation(),
                            child: Icon(Icons.location_pin),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return Colors.orange;
                              },
                            )),
                          ),
                        ),
                        // color: Colors.amber)
                      ),
                    ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return new AlertDialog(
                                title: Text('Vérification de la connexion',
                                    textAlign: TextAlign.center),
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                    )
                                  ],
                                ));
                          },
                          barrierDismissible: false);
                      bool result = await DataConnectionChecker().hasConnection;
                      if (result == true) {
                        Navigator.of(context).pop();
                        if (loaded == null || located == null) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return new AlertDialog(
                                  title: Text('Erreur',
                                      textAlign: TextAlign.center),
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'Veuillez renseigner la localisation et la photo',
                                          textAlign: TextAlign.center),
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 50),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Fermer'),
                                        style: ButtonStyle(backgroundColor:
                                            MaterialStateProperty.resolveWith<
                                                Color>(
                                          (Set<MaterialState> states) {
                                            return Colors.red;
                                          },
                                        )),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              barrierDismissible: false);
                        } else {
                          if (lundi.text == "" &&
                              mardi.text == "" &&
                              mercredi.text == "" &&
                              jeudi.text == "" &&
                              vendredi.text == "" &&
                              samedi.text == "" &&
                              dimanche.text == "") {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return new AlertDialog(
                                    title: Text('Erreur',
                                        textAlign: TextAlign.center),
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            'Impossible d\'enregistrer une vendeuse sans aucun horaire de vente',
                                            textAlign: TextAlign.center),
                                        Icon(Icons.error_outline,
                                            color: Colors.red, size: 50),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('Fermer'),
                                          style: ButtonStyle(backgroundColor:
                                              MaterialStateProperty.resolveWith<
                                                  Color>(
                                            (Set<MaterialState> states) {
                                              return Colors.red;
                                            },
                                          )),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                barrierDismissible: false);
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => EnregistrementD(),
                                barrierDismissible: false);
                            Vendeuse vendeuse = Vendeuse(
                                nom.text.toString().toUpperCase(),
                                tel.text.toString(),
                                _currentPosition.longitude,
                                _currentPosition.latitude,
                                adresse,
                                localite,
                                lundi.text.toString().toUpperCase(),
                                mardi.text.toString().toUpperCase(),
                                mercredi.text.toString().toUpperCase(),
                                jeudi.text.toString().toUpperCase(),
                                vendredi.text.toString().toUpperCase(),
                                samedi.text.toString().toUpperCase(),
                                dimanche.text.toString().toUpperCase());
                            QuerySnapshot v = await vendeuse.testAjout();
                            if (v.docs.length > 0) {
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return new AlertDialog(
                                      title: Text('Erreur',
                                          textAlign: TextAlign.center),
                                      content: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              'Ce numéro de téléphone existe déjà dans la base de données',
                                              textAlign: TextAlign.center),
                                          Icon(Icons.error_outline,
                                              color: Colors.red, size: 50),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('Fermer'),
                                            style: ButtonStyle(backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                return Colors.red;
                                              },
                                            )),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  barrierDismissible: false);
                            } else {
                              await vendeuse.ajoutImage(_image);
                              if (vendeuse.photo == null) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return new AlertDialog(
                                          title: Text('Erreur'),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  'Impossible de charger la photo',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                  textAlign: TextAlign.center),
                                              Icon(Icons.error_outline,
                                                  color: Colors.red, size: 50),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('Fermer'),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    return Colors.red;
                                                  },
                                                )),
                                              ),
                                            ],
                                          ));
                                    });
                              } else {
                                await vendeuse.ajoutVendeuse();
                                if (vendeuse.id != null) {
                                  Navigator.of(context).pop();
                                  _formKey.currentState.reset();
                                  showDialog(
                                      context: context,
                                      builder: (context) => SuccesD(),
                                      barrierDismissible: false);
                                } else {
                                  Navigator.of(context).pop();
                                  _formKey.currentState.reset();
                                  showDialog(
                                      context: context,
                                      builder: (context) => ErrorD(),
                                      barrierDismissible: false);
                                }
                                nom.clear();
                                tel.clear();
                                lundi.clear();
                                mardi.clear();
                                mercredi.clear();
                                jeudi.clear();
                                vendredi.clear();
                                samedi.clear();
                                dimanche.clear();
                                setState(() {
                                  loaded = false;
                                  located = false;
                                });
                              }
                            }
                          }
                        }
                      } else {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return new AlertDialog(
                                  title: Text('Aucune connexion internet',
                                      textAlign: TextAlign.center),
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 50),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Fermer'),
                                        style: ButtonStyle(backgroundColor:
                                            MaterialStateProperty.resolveWith<
                                                Color>(
                                          (Set<MaterialState> states) {
                                            return Colors.red;
                                          },
                                        )),
                                      ),
                                    ],
                                  ));
                            },
                            barrierDismissible: false);
                      }
                    }
                  },
                  child: Text('Enregistrer', style: TextStyle(fontSize: 20.0)),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.orange;
                    },
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
