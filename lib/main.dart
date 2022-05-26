import 'package:allocomaps/InfoVendeuse.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:allocomaps/model/Vendeuse.dart';
import 'package:allocomaps/EcranAjout.dart';
import 'package:allocomaps/ListeVendeuses.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Vendeuse.intialiseFireBaseApp();
  runApp(new Allocomaps());
}

class Allocomaps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'AllocoMaps',
      debugShowCheckedModeBanner: false,
      home: new Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> {
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 10,
        navigateAfterSeconds: new Home(),
        title: new Text(
          'AllocoMaps',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset('assets/logo/logomaps.png'),
        backgroundColor: Colors.white,
        loaderColor: Colors.orange,
        photoSize: 50.0);
  }
}

class Home extends StatefulWidget {
  final vendeusesRecherchees;
  const Home({Key key, this.vendeusesRecherchees}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  GoogleMapController _controller;
  List<Marker> allMarkers = [];

  // Set<Marker> _markers = {};
  PageController _pageController = new PageController();
  static geo.Position _currentPosition;
  int prevPage;

  /*= new geo.Position(longitude: null, latitude: null, timestamp: null, accuracy: null, altitude: null, heading: null, speed: null, speedAccuracy: null);*/
  BitmapDescriptor iconMarqueur;
  Set<Marker> _markers = Set<Marker>();
  bool located;
  List vendeuses = [];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement ini
    if (widget.vendeusesRecherchees == null) {
      Vendeuse.recupererVendeuses().then((value) {
        setState(() {
          vendeuses = value;
          geo.Geolocator.getCurrentPosition(
                  desiredAccuracy: geo.LocationAccuracy.best)
              .then((value) {
            setState(() {
              _currentPosition = value;
            });
          });
        });
      });
    } else {
      geo.Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.best)
          .then((value) {
        setState(() {
          vendeuses = widget.vendeusesRecherchees;
          _currentPosition = value;
        });
      });
    }
    setCustomMarkers();
  }

  setCustomMarkers() async {
    var iconMarqueur = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 6.5),
      'assets/marker/markerAllocoMap.png',
    );
    setState(() {
      this.iconMarqueur = iconMarqueur;
    });
  }

  void _onMapCreated(controller) {
    setState(() {
      vendeuses.forEach((element) {
        allMarkers.add(Marker(
            draggable: false,
            icon: iconMarqueur,
            markerId: MarkerId(element.nom),
            infoWindow: InfoWindow(
              title: element.nom,
              //snippet: element.address,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InfoVendeuse(
                            id: element.id,
                            nomVendeuse: element.nom,
                            numeroDeTelephone: element.numeroDeTelephone,
                            adresse: element.adresse,
                            photo: element.photo,
                            lundi: element.lundi,
                            mardi: element.mardi,
                            mercredi: element.mercredi,
                            jeudi: element.jeudi,
                            vendredi: element.vendredi,
                            samedi: element.samedi,
                            dimanche: element.dimanche,
                            localite: element.localite)));
              },
            ),
            position: LatLng(element.latitude, element.longitude)));
      });
      _controller = controller;
      _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
        ..addListener(_onScroll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AllocoMaps"),
        leading: widget.vendeusesRecherchees != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (builder) => Home())))
            : null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(vendeuses));
            },
          ),
        ],
        backgroundColor: Colors.orange,
      ),
      body: Visibility(
        child: Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))),
        replacement: Stack(
          children: <Widget>[
            Container(
              //affichage de la carte GoogleMap
              child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  tiltGesturesEnabled: true,
                  cameraTargetBounds: CameraTargetBounds.unbounded,
                  minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                  mapType: MapType.normal,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  indoorViewEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition == null
                        ? LatLng(0, 0)
                        : LatLng(_currentPosition.latitude,
                            _currentPosition.longitude),
                    zoom: 15.0,
                  ),
                  markers: Set.from(allMarkers),
                  //onMapCreated: mapCreated,
                  onMapCreated: _onMapCreated),

              //box pour l'aperçu vendeuse
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: vendeuses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _vendeusesList(index);
                  },
                ),
              ),
            )
          ],
        ),
        visible: _currentPosition == null,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Que voulez-vous ?'),
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
            ),
            ListTile(
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ajouter une vendeuse"),
                    Icon(Icons.add, color: Colors.orange),
                  ],
                ),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EcranAjout()))),
            ListTile(
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Liste des vendeuses"),
                    Icon(Icons.list_alt_outlined, color: Colors.orange),
                  ],
                ),
                onTap: () async {
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListeVendeuse()));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return new AlertDialog(
                              title:
                                  Text('Erreur', textAlign: TextAlign.center),
                              content: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Aucune connexion internet',
                                      style: TextStyle(color: Colors.red),
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
                              ));
                        },
                        barrierDismissible: false);
                  }
                }),
          ],
        ),
      ),
    );
  }

//******************************************
/*  Future<LocationData> currentLocation;
  Location location;*/
//******************************************
//******************************************
  //localisation de la propre position actuelle
  _vendeusesList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 200.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
          onTap: () {
            moveCamera();
          },
          child: Stack(children: [
            Center(
                child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    height: 100.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(0.0, 4.0),
                            blurRadius: 10.0,
                          ),
                        ]),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: Row(children: [
                          Flexible(
                            child: Container(
                                height: 100.0,
                                width: 80.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        topLeft: Radius.circular(8.0)),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            '${vendeuses[index].photo}'),
                                        fit: BoxFit.cover))),
                          ),
                          // SizedBox(width: 3.0),
                          Padding(
                            padding: EdgeInsets.only(right: 8, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${vendeuses[index].nom}',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      vendeuses[index].adresse,
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => InfoVendeuse(
                                                  id: vendeuses[index].id,
                                                  nomVendeuse:
                                                      vendeuses[index].nom,
                                                  numeroDeTelephone:
                                                      vendeuses[index]
                                                          .numeroDeTelephone,
                                                  adresse:
                                                      vendeuses[index].adresse,
                                                  photo: vendeuses[index].photo,
                                                  lundi: vendeuses[index].lundi,
                                                  mardi: vendeuses[index].mardi,
                                                  mercredi:
                                                      vendeuses[index].mercredi,
                                                  jeudi: vendeuses[index].jeudi,
                                                  vendredi:
                                                      vendeuses[index].vendredi,
                                                  samedi:
                                                      vendeuses[index].samedi,
                                                  dimanche:
                                                      vendeuses[index].dimanche,
                                                  localite: vendeuses[index]
                                                      .localite))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Lire plus'),
                                          Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                      style: ButtonStyle(backgroundColor:
                                          MaterialStateProperty.resolveWith<
                                              Color>(
                                        (Set<MaterialState> states) {
                                          return Colors.orange;
                                        },
                                      )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]))))
          ])),
    );
  }

//******************************************
//faire bouger la camera
  void moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: vendeuses.length == 0
            ? LatLng(_currentPosition.latitude, _currentPosition.longitude)
            : LatLng(vendeuses[_pageController.page.toInt()].latitude,
                vendeuses[_pageController.page.toInt()].longitude),
        zoom: 15.0,
        bearing: 45.0,
        tilt: 45.0)));
  }

  //******************************************
  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      moveCamera();
    }
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
              Text('Veuillez saisir une adresse, un quartier ou un lieu',
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
              element.adresse.toUpperCase().contains(query.toUpperCase()))
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
                  Text('Aucune vendeuse ne correspond à cette adresse',
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
              title: Text(listeRecherche[index].adresse),
              onTap: () {
                query = listeRecherche[index].adresse;
                var vendeusesRecherchees = this
                    .vendeuses
                    .where((element) => element.adresse
                        .toUpperCase()
                        .contains(query.toUpperCase()))
                    .toList();
                close(context, null);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ListeVendeuse(
                            vendeusesRecherchees: vendeusesRecherchees)));
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
                element.adresse.toUpperCase().contains(query.toUpperCase()))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.search),
        title: Text(suggestions[index].adresse),
        onTap: () {
          query = suggestions[index].adresse;
          var vendeusesRecherchees = this
              .vendeuses
              .where((element) =>
                  element.adresse.toUpperCase().contains(query.toUpperCase()))
              .toList();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) =>
                      Home(vendeusesRecherchees: vendeusesRecherchees)));

          // showResults(context);
        },
      ),
      itemCount: suggestions.length,
    );
  }
}
