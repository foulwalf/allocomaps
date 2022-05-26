import 'package:flutter/material.dart';
//import 'package:allocomap/vendeuse_model.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoVendeuse extends StatelessWidget {
  InfoVendeuse(
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
      @required this.localite})
      : super(key: key);
  final String id;
  final String nomVendeuse;
  final String adresse;
  final String localite;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Plus d\'informations'),
      ),
      body: HomePage(
          nomVendeuse: this.nomVendeuse,
          adresse: this.adresse,
          localite: this.localite,
          numeroDeTelephone: this.numeroDeTelephone,
          photo: this.photo,
          lundi: this.lundi,
          mardi: this.mardi,
          mercredi: this.mercredi,
          jeudi: this.jeudi,
          vendredi: this.vendredi,
          samedi: this.samedi,
          dimanche: this.dimanche),
    );
  }
}

class HomePage extends StatelessWidget {
  // recuperer les paramètres de la page main
  HomePage(
      {Key key,
      this.id,
      this.nomVendeuse,
      this.adresse,
      this.numeroDeTelephone,
      this.photo,
      this.lundi,
      this.mardi,
      this.mercredi,
      this.jeudi,
      this.vendredi,
      this.samedi,
      this.dimanche,
      this.localite})
      : super(key: key);

  final String id;
  final String nomVendeuse;
  final String adresse;
  final String numeroDeTelephone;
  final String photo;
  final String lundi;
  final String mardi;
  final String mercredi;
  final String jeudi;
  final String vendredi;
  final String samedi;
  final String dimanche;
  final String localite;

  Widget build(BuildContext context) {
    Widget titleSection = Container(
      child: Text('$nomVendeuse',
          style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
      padding: const EdgeInsets.all(12),
    );

    //Color color = Theme.of(context).primaryColor;
    Widget infoSection = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ListTile(
            title:
                Text('$adresse', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$localite'),
            leading: Icon(
              Icons.location_on_outlined,
              color: Colors.orange[300],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('$numeroDeTelephone',
                style: TextStyle(fontWeight: FontWeight.bold)),
            leading: Icon(
              Icons.call_rounded,
              color: Colors.orange[300],
            ),
          ),

          /*
          _buildButtonColumn(color, Icons.call, 'Joindre'),
          Text("0710487172"),
          _buildButtonColumn(color, Icons.near_me, 'Se déplacer'),
          //  _buildButtonColumn(color, Icons.share, 'Partager'),
          */
          Divider(),
          ListTile(
            leading: Icon(
              Icons.event_available_sharp,
              color: Colors.orange[300],
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Horaires \n',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                this.lundi != ''
                    ? Row(
                        children: [
                          Text('Lundi : '),
                          Text('${this.lundi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.mardi != ''
                    ? Row(
                        children: [
                          Text('Mardi : '),
                          Text('${this.mardi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.mercredi != ''
                    ? Row(
                        children: [
                          Text('Mercredi : '),
                          Text('${this.mercredi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.jeudi != ''
                    ? Row(
                        children: [
                          Text('Jeudi : '),
                          Text('${this.jeudi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.vendredi != ''
                    ? Row(
                        children: [
                          Text('Vendrid : '),
                          Text('${this.vendredi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.samedi != ''
                    ? Row(
                        children: [
                          Text('Samedi : '),
                          Text('${this.samedi}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
                this.dimanche != ''
                    ? Row(
                        children: [
                          Text('Dimanche : '),
                          Text('${this.dimanche}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\n')
                        ],
                      )
                    : null,
              ],
            ),
          ),
        ],
      ),
    );

    Widget imageSection = Container(
        margin: EdgeInsets.all(20),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage('$photo'),
            )));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          children: [
            imageSection,
            titleSection,
            infoSection,
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.call),
          backgroundColor: Colors.orange,
          onPressed: () async {
            String num = 'tel:$numeroDeTelephone';
            if (await canLaunch(num) != null) {
              await launch(num);
            } else {
              print('Could not launch $numeroDeTelephone');
            }
          },
        ),
      ),
    );
  }
}
