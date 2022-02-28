import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/tamp.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String weather = "clear";
  String abbr = "lc";
  String location = "City";
  int temperature = 0;
  int woeid = 0;



  Future<void> fetchcity(String input) async {
    var url = Uri.parse(
        "https://www.metaweather.com/api/location/search/?query=$input");
    var searchResult = await http.get(url);
    var resultbody = jsonDecode(searchResult.body)[0];
    setState(() {
      location = resultbody["title"];
      woeid = resultbody["woeid"];
    });
  }


  Future<void> fetchtamp() async {
    var url = Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var searchResult = await http.get(url);
    var resultbody = jsonDecode(searchResult.body)["consolidated_weather"][0];
    setState(() {
      temperature = resultbody["the_temp"].round();
      abbr = resultbody["weather_state_abbr"];
      weather = resultbody["weather_state_name"].replaceAll(' ','').toLowerCase();
    });
  }

    Future<List<temp>> fetchtamplist() async {
    List<temp> list =[];
    var url = Uri.parse("https://www.metaweather.com/api/location/$woeid");
    var searchResult = await http.get(url);
    var resultbody = jsonDecode(searchResult.body)["consolidated_weather"];

    for (var i in resultbody )
    {
      temp x = temp(
          applicable_date: i["applicable_date"],max_temp: i["max_temp"],min_temp: i["min_temp"],weather_state_abbr: i["weather_state_abbr"]);
          list.add(x);
    }
    return list;
  }

  Future<void> onTextFieldSubmitted(String input) async {
    await fetchcity(input);
    await fetchtamp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/$weather.png"),fit :BoxFit.cover
          ),
        ),
        child: Scaffold(
           backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: 
            [
              Column(
                children:
                [
                  Center(
                    child: Image.network("https://www.metaweather.com/static/img/weather/png/$abbr.png",
                      width: 100,),
                  ),
                  Center(child: Text("$temperature °C",style: TextStyle(fontSize: 45,fontWeight: FontWeight.bold),),
                  ),
                  Center(child: Text("$location ",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/1.1,
                    child: TextField(
                      onSubmitted: (String input)
                      {

                        print(input);
                        onTextFieldSubmitted(input);
                      },
                      style:TextStyle(
                        fontSize: 22,),
                      decoration: InputDecoration(

                        hintText: "Search anther location .....",
                        hintStyle: TextStyle(
                          fontSize: 20,fontWeight: FontWeight.bold
                        ),
                        prefixIcon: Icon(Icons.search_outlined,color: Colors.black,size: 35,)
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                    child: Container(
                      height:170 ,
                      child: FutureBuilder(
                        future: fetchtamplist(),
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(

                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                    height: 170,
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children:
                                      [
                                        Text("Date:${snapshot.data[index].applicable_date}",
                                          style: TextStyle(color: Colors.black,
                                            fontWeight: FontWeight.w800,),
                                          textAlign: TextAlign.center,),
                                        Image.network(
                                          "https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",
                                          width: 40, height: 40,),
                                        Text("$location ", style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),),
                                        Text(" Min: ${snapshot.data[index].min_temp.round()} ", style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15),),
                                        Text("Max: ${snapshot.data[index].max_temp.round()} ", style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17),),


                                      ],
                                    ),
                                  ),


                                );
                              },);
                          }else return Center(child: Text(""));

                        })
                    ),
                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
