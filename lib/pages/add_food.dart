import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'services/crud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFood extends StatefulWidget{
  final bool isSeeker;
  const AddFood({@required this.isSeeker});

  @override
  _AddFoodState createState() => _AddFoodState(isSeeker);
}

class _AddFoodState extends State<AddFood> {
  bool isSeeker;
   _AddFoodState(bool _isSeeker){
    this.isSeeker = _isSeeker;
   }

  String foodType;
  String location;

  QuerySnapshot food;

  crudMethods crudObj = new crudMethods();

  void addToList(String query, String foodtype) async{
    final addQuery = query;
    var addresses = await Geocoder.local.findAddressesFromQuery(addQuery);
    if(addresses.length != 0){
      var first = addresses.first;
      GeoPoint target = new GeoPoint(first.coordinates.latitude, first.coordinates.longitude);
      var address = first.addressLine;
      crudObj.addData({
        'FoodType': foodType,
        'Location': target,
        'Address': address
      });
      Fluttertoast.showToast(
        msg: "Added food at $address",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
    else {
      Fluttertoast.showToast(
        msg: "Address not found...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

//
//  Future<bool> _checkIfSeeker() async{
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var value=  prefs.getBool("isFoodSeeker");
//    print("MY STATUS IS " + (value).toString());
//    return value;
//  }

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add sum food to share', style: TextStyle(fontSize: 20.0)),
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Food Type'),
                  onChanged: (value) {
                    this.foodType = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Location'),
                  onChanged: (value) {
                    this.location = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () {
                  if(this.foodType == null){
                    Fluttertoast.showToast(
                    msg: "Please enter a food type...",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                    );
                  }
                  else if (this.location == null){
                    Fluttertoast.showToast(
                    msg: "Please enter a location...",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                    );
                  }
                  else{
                    Navigator.of(context).pop();
                    addToList(this.location, this.foodType);
                  }
                },
              )
            ],
          );
        });
  }

  @override
  void initState(){
    crudObj.getData().then((results) {
      setState(() {
        food = results;
      });
    });
    super.initState();
  }

//  var isSeeker;

//  Widget _addIcon(){
//    var _icon;
//    this._checkIfSeeker().then((results) {
//      print("MY RESULTS ARE " + results.toString());
//      isSeeker = results;
//      return _icon = (!isSeeker) ? IconButton(
//          icon: Icon(Icons.add),
//          onPressed: () {
//            addDialog(context);
//          }
//      ): Text("");
//  });
//  }


  @override
  Widget build (BuildContext context) {
      print("ADD FOOD IS " + isSeeker.toString());
      return new Scaffold(
        appBar: AppBar(
          title: Text('Share Sum Food'),
          actions: <Widget>[
            (this.isSeeker) ? Text("") : IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            addDialog(context);
            }
          ) ,
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                crudObj.getData().then((results) {
                  setState(() {
                    food = results;
                  });
                });
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
                child: _foodList()
            ),
          ],
        ),
      );
  }

  Widget _foodList(){
    if (food != null) {
      return ListView.builder(
        itemCount: food.documents.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, i) {
          return new ListTile(
            title: Text(food.documents[i].data['FoodType']),
            subtitle: Text(food.documents[i].data['Address']),
          );
        }
      );
    }
    else {
      return Text('Loading...');
    }
  }
}