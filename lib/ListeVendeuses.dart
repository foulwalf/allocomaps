import 'package:allocomaps/EcranModif.dart';
import 'package:allocomaps/main.dart';
import 'package:allocomaps/model/Vendeuse.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:allocomaps/InfoVendeuse.dart';

class ListeVendeuse extends StatefulWidget {
  final vendeusesRecherchees;

  const ListeVendeuse({Key key, this.vendeusesRecherchees}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Liste();
  }
}

// ou est le drawer
class Liste extends State<ListeVendeuse> {
  List vendeuses = [];
  bool loading = true;
  bool confirmer = false;
  bool searchOff = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = true;
    if (widget.vendeusesRecherchees == null) {
      Vendeuse.recupererVendeuses().then((value) {
        setState(() {
          vendeuses = value;
          loading = false;
        });
      });
    } else {
      setState(() {
        vendeuses = widget.vendeusesRecherchees;
        loading = false;
      });
    }
  }

  Widget ConfirmationD(String texte) {
    return new AlertDialog(
      title: Center(child: Text('Confirmation')),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Voulez vraiment $texte ?', textAlign: TextAlign.center),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop(true);
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.orange;
                    },
                  )),
                  child: Text("Oui", style: TextStyle(color: Colors.white)),
                ),
              ),
              Container(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.orange;
                    },
                  )),
                  child: Text("Non", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          title: Text("Liste des vendeuses"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch(vendeuses));
              },
            ),
          ],
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.vendeusesRecherchees == null) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (builder) => Home()));
              } else {
                Navigator.of(context).pop();
              }
            },
          )),
      body: Visibility(
        child: Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))),
        replacement: vendeuses.length != 0
            ? ListView.builder(
                itemCount: vendeuses.length,
                itemExtent: 70,
                itemBuilder: (context, index) {
                  return new Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          // backgroundColor: Colors.orange,
                          backgroundImage:
                              NetworkImage('${vendeuses[index].photo}'),
                        ),
                        title: Text(vendeuses[index].nom),
                        subtitle: Row(
                          children: [
                            vendeuses[index].lundi != ""
                                ? Text('Lun')
                                : Text(''),
                            vendeuses[index].mardi != ""
                                ? Text(', Mar')
                                : Text(''),
                            vendeuses[index].mercredi != ""
                                ? Text(', Mer')
                                : Text(''),
                            vendeuses[index].jeudi != ""
                                ? Text(', Jeu')
                                : Text(''),
                            vendeuses[index].vendredi != ""
                                ? Text(', Ven')
                                : Text(''),
                            vendeuses[index].samedi != ""
                                ? Text(', Sam')
                                : Text(''),
                            vendeuses[index].dimanche != ""
                                ? Text(', Dim')
                                : Text(''),
                          ],
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InfoVendeuse(
                                      id: vendeuses[index].id,
                                      nomVendeuse: vendeuses[index].nom,
                                      numeroDeTelephone:
                                          vendeuses[index].numeroDeTelephone,
                                      adresse: vendeuses[index].adresse,
                                      photo: vendeuses[index].photo,
                                      lundi: vendeuses[index].lundi,
                                      mardi: vendeuses[index].mardi,
                                      mercredi: vendeuses[index].mercredi,
                                      jeudi: vendeuses[index].jeudi,
                                      vendredi: vendeuses[index].vendredi,
                                      samedi: vendeuses[index].samedi,
                                      dimanche: vendeuses[index].dimanche,
                                      localite: vendeuses[index].localite)));
                        },
                      ),
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                          caption: 'Modifier',
                          color: Colors.orange,
                          icon: Icons.edit,
                          onTap: () async {
                            var resultat = await showDialog(
                                context: context,
                                builder: (context) => ConfirmationD(
                                    'Modifier les informations de cette vendeuse'),
                                barrierDismissible: false);
                            if (resultat) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return new AlertDialog(
                                        title: Text(
                                            'Vérification de la connexion',
                                            textAlign: TextAlign.center),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: 50,
                                              height: 50,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4,
                                                backgroundColor: Colors.grey,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.orange),
                                              ),
                                            )
                                          ],
                                        ));
                                  },
                                  barrierDismissible: false);
                              bool result =
                                  await DataConnectionChecker().hasConnection;
                              if (result == true) {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EcranModif(
                                              id: vendeuses[index].id,
                                              nomVendeuse: vendeuses[index].nom,
                                              numeroDeTelephone:
                                                  vendeuses[index]
                                                      .numeroDeTelephone,
                                              adresse: vendeuses[index].adresse,
                                              photo: vendeuses[index].photo,
                                              lundi: vendeuses[index].lundi,
                                              mardi: vendeuses[index].mardi,
                                              mercredi:
                                                  vendeuses[index].mercredi,
                                              jeudi: vendeuses[index].jeudi,
                                              vendredi:
                                                  vendeuses[index].vendredi,
                                              samedi: vendeuses[index].samedi,
                                              dimanche:
                                                  vendeuses[index].dimanche,
                                              latitude:
                                                  vendeuses[index].latitude,
                                              longitude:
                                                  vendeuses[index].longitude,
                                              localite:
                                                  vendeuses[index].localite,
                                            )));
                              } else {
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return new AlertDialog(
                                          title: Text(
                                              'Aucune connexion internet',
                                              textAlign: TextAlign.center),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                    },
                                    barrierDismissible: false);
                              }
                            }
                          }),
                      IconSlideAction(
                        caption: 'Supprimer',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () async {
                          var resultat = await showDialog(
                              context: context,
                              builder: (context) =>
                                  ConfirmationD('Supprimer cette vendeuse'),
                              barrierDismissible: false);
                          if (resultat) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return new AlertDialog(
                                      title: Text('Suppression',
                                          textAlign: TextAlign.center),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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

                            Vendeuse vendeuse = new Vendeuse(
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null);
                            vendeuse.id = vendeuses[index].id;
                            vendeuse.photo = vendeuses[index].photo;
                            var v = await vendeuse.supprimerVendeuse();
                            var test = await vendeuse.suppImage();
                            if (!v.exists) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return new AlertDialog(
                                        title: Text('Vendeuse supprimée',
                                            textAlign: TextAlign.center),
                                        content: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_outline,
                                                color: Colors.orange, size: 50),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListeVendeuse()));
                                              },
                                              child: Text('Fermer'),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  return Colors.orange;
                                                },
                                              )),
                                            ),
                                          ],
                                        ));
                                  });
                            } else {
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
                                              'Une erreur s\'est produite lors de la suppression, veuilez réessayer',
                                              style:
                                                  TextStyle(color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                            Icon(Icons.error_outline,
                                                color: Colors.red, size: 50),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListeVendeuse()));
                                              },
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
                          }
                        },
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  Text('Aucune vendeuse enregistrée',
                      style: TextStyle(color: Colors.red)),
                ],
              )),
        visible: loading,
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  List vendeuses = [];

  DataSearch(List vendeuses) {
    this.vendeuses = vendeuses;
  }

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => 'Recherche...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 40,
                color: Colors.red,
              ),
              Text('Veuillez saisir le nom de la vendeuse recherchée',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))
            ],
          )
        ]),
      );
    } else {
      final listeRecherche = this
          .vendeuses
          .where((element) =>
              element.nom.toUpperCase().contains(query.toUpperCase()))
          .toList();
      switch (listeRecherche.length) {
        case 0:
          return Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 40,
                    color: Colors.black,
                  ),
                  Text('Aucune vendeuse ne correspond à votre recherche',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold))
                ],
              )
            ]),
          );
          break;

        default:
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.search),
              title: Text(listeRecherche[index].nom),
              // subtitle: Row(
              //   children: [
              //     Text(suggestions[index].numeroDeTelephone),
              //     Text(suggestions[index].adresse),
              //   ],
              // ),

              onTap: () {
                query = listeRecherche[index].nom;
                var vendeusesRecherchees = this
                    .vendeuses
                    .where((element) =>
                        element.nom.toUpperCase().contains(query.toUpperCase()))
                    .toList();
                close(context, null);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ListeVendeuse(
                            vendeusesRecherchees: vendeusesRecherchees)));

                // showResults(context);
              },
            ),
            itemCount: listeRecherche.length,
          );
      }
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : this
            .vendeuses
            .where((element) =>
                element.nom.toUpperCase().contains(query.toUpperCase()))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.search),
        title: Text(suggestions[index].nom),
        // subtitle: Row(
        //   children: [
        //     Text(suggestions[index].numeroDeTelephone),
        //     Text(suggestions[index].adresse),
        //   ],
        // ),

        onTap: () {
          query = suggestions[index].nom;
          var vendeusesRecherchees = this
              .vendeuses
              .where((element) =>
                  element.nom.toUpperCase().contains(query.toUpperCase()))
              .toList();
          close(context, null);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => ListeVendeuse(
                      vendeusesRecherchees: vendeusesRecherchees)));

          // showResults(context);
        },
      ),
      itemCount: suggestions.length,
    );
  }
}
