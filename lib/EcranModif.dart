import 'dart:io';
import 'package:allocomaps/ListeVendeuses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allocomaps/model/Vendeuse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class EcranModif extends StatefulWidget {
  EcranModif(
      {Key key,
      @required this.id,
      @required this.nomVendeuse,
      @required this.adresse,
      @required this.numeroDeTelephone,
      @required this.photo,
      @required this.lundi,
      @required this.mardi,
      @required this.mercredi,
      @required this.jeudi,
      @required this.vendredi,
      @required this.samedi,
      @required this.dimanche,
      this.latitude,
      this.longitude,
      this.localite})
      : super(key: key);
  final String id;
  final String nomVendeuse;
  final String adresse;
  final String localite;
  final double latitude;
  final double longitude;
  final String numeroDeTelephone;
  final String photo;
  final String lundi;
  final String mardi;
  final String mercredi;
  final String jeudi;
  final String vendredi;
  final String samedi;
  final String dimanche;

  @override
  State<StatefulWidget> createState() {
    //TODO: implement createState
    return new Screen();
  }
}

class Screen extends State<EcranModif> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Geolocator geolocator = Geolocator();
  File _image;
  Position _currentPosition;
  String adresse;
  String localite;
  bool located;
  bool loaded;
  RegExp horaire = new RegExp(r'^(\d\d|\d)H(\d\d|\d|)[-](\d\d|\d)H(\d\d|\d|)$',
      caseSensitive: false, multiLine: false, dotAll: false, unicode: false);
  RegExp contact = new RegExp(r'(\+\d{3}|)\d{10}$',
      caseSensitive: false, multiLine: false, dotAll: false, unicode: false);
  TextEditingController cnom = new TextEditingController();
  TextEditingController ctel = new TextEditingController();
  TextEditingController clundi = new TextEditingController();
  TextEditingController cmardi = new TextEditingController();
  TextEditingController cmercredi = new TextEditingController();
  TextEditingController cjeudi = new TextEditingController();
  TextEditingController cvendredi = new TextEditingController();
  TextEditingController csamedi = new TextEditingController();
  TextEditingController cdimanche = new TextEditingController();
  Vendeuse vendeuse = new Vendeuse(null, null, null, null, null, null, null,
      null, null, null, null, null, null);

  @override
  void initState() {
    super.initState();
    setState(() {
      vendeuse = new Vendeuse(
          widget.nomVendeuse,
          widget.numeroDeTelephone,
          widget.longitude,
          widget.latitude,
          widget.adresse,
          widget.localite,
          widget.lundi,
          widget.mardi,
          widget.mercredi,
          widget.jeudi,
          widget.vendredi,
          widget.samedi,
          widget.dimanche);
      vendeuse.id = widget.id;
      vendeuse.photo = widget.photo;
    });
  }

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

  Widget ModificationD() {
    return new AlertDialog(
        title: Text('Modification', textAlign: TextAlign.center),
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
        title: Text('Vendeuse modifiée', textAlign: TextAlign.center),
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
                style: TextStyle(color: Colors.red)),
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
        ));
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
        title: Text("Modifier une vendeuse"),
        backgroundColor: Colors.orange,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (builder) => ListeVendeuse()))),
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
                controller: cnom..text = widget.nomVendeuse,
                onChanged: (text) => {},
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
                controller: ctel..text = widget.numeroDeTelephone,
                onChanged: (text) => {},
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
                controller: clundi..text = widget.lundi,
                onChanged: (text) => {},
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
                controller: cmardi..text = widget.mardi,
                onChanged: (text) => {},
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
                controller: cmercredi..text = widget.mercredi,
                onChanged: (text) => {},
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
                controller: cjeudi..text = widget.jeudi,
                onChanged: (text) => {},
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
                controller: cvendredi..text = widget.vendredi,
                onChanged: (text) => {},
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
                controller: csamedi..text = widget.samedi,
                onChanged: (text) => {},
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
                controller: cdimanche..text = widget.dimanche,
                onChanged: (text) => {},
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
                        visible: loaded ?? false,
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
                        visible: located ?? false,
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
                        if (located == true) {
                          setState(() {
                            vendeuse.longitude = _currentPosition.longitude;
                            vendeuse.latitude = _currentPosition.latitude;
                            vendeuse.adresse = adresse;
                          });
                        }
                        if (clundi.text == "" &&
                            cmardi.text == "" &&
                            cmercredi.text == "" &&
                            cjeudi.text == "" &&
                            cvendredi.text == "" &&
                            csamedi.text == "" &&
                            cdimanche.text == "") {
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
                                          'Veuillez renseigner au moins un horaire'),
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
                              builder: (context) => ModificationD(),
                              barrierDismissible: false);
                          setState(() {
                            vendeuse.nom = cnom.text.toString().toUpperCase();
                            vendeuse.numeroDeTelephone = ctel.text.toString();
                            vendeuse.lundi =
                                clundi.text.toString().toUpperCase();
                            vendeuse.mardi =
                                cmardi.text.toString().toUpperCase();
                            vendeuse.mercredi =
                                cmercredi.text.toString().toUpperCase();
                            vendeuse.jeudi =
                                cjeudi.text.toString().toUpperCase();
                            vendeuse.vendredi =
                                cvendredi.text.toString().toUpperCase();
                            vendeuse.samedi =
                                csamedi.text.toString().toUpperCase();
                            vendeuse.dimanche =
                                cdimanche.text.toString().toUpperCase();
                          });
                          if (loaded == true) {
                            var suppression = await vendeuse.suppImage();
                            if (suppression == true) {
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
                                                      color: Colors.red)),
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
                                await vendeuse.modifierVendeuse();
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
                                setState(() {
                                  cnom.clear();
                                  ctel.clear();
                                  clundi.clear();
                                  cmardi.clear();
                                  cmercredi.clear();
                                  cjeudi.clear();
                                  cvendredi.clear();
                                  csamedi.clear();
                                  cdimanche.clear();
                                  loaded = false;
                                  located = false;
                                });
                              }
                            } else {
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
                                                'Erreur pendant la modification de la photo',
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                            }
                          } else {
                            await vendeuse.modifierVendeuse();
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
                            setState(() {
                              cnom.clear();
                              ctel.clear();
                              clundi.clear();
                              cmardi.clear();
                              cmercredi.clear();
                              cjeudi.clear();
                              cvendredi.clear();
                              csamedi.clear();
                              cdimanche.clear();
                              loaded = false;
                              located = false;
                            });
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
                  child: Text('Modifier', style: TextStyle(fontSize: 20.0)),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.orange;
                    },
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
