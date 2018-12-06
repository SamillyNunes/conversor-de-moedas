import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; //permite fazer as requisicoes

import 'dart:async'; //permite que faca requisicoes e n tenha que ficar esperando
import 'dart:convert';

const request =
    'https://api.hgbrasil.com/finance?format=json&key=1a11babe'; //verificar se eh realmente essa chave depois / endereco da requisicao da api

void main() async {
  //async faz com que seja uma aplicacao assincrona

  print(
      await getData()); //await para ficar esperando a requisicao mas o app funfar normalmente

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        //tema para o app inteiro
        hintColor: Colors.amber, //cor da dica
        primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  //Retorna um dado do futuro (quando a requisicao chega, oq demora) e eh async (pra nao ficar esperando)
  http.Response response =
      await http.get(request); //o await faz com que espere os dados

  return json.decode(
      response.body); //json.decode eh a conversao da requisicao para json
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController(); 

  void _realChanged(String text){
    double real= double.parse(text);
    dolarController.text=(real/dolar).toStringAsFixed(2); //muda o campo do dolar e arredonda pra 2 casas decimas
    euroController.text=(real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    double dolar = double.parse(text); //variavel local. Para usar o dolar antes declarado usaria o this.dolar
    realController.text=(dolar*this.dolar).toStringAsFixed(2);
    euroController.text=(dolar*this.dolar / euro).toStringAsFixed(2);
  
  }

  void _euroChanged(String text){
    double euro = double.parse(text);
    realController.text=(euro*this.euro).toStringAsFixed(2);
    dolarController.text=(euro*this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "\$ Conversor de Moedas \$", //para colocar um simbolo usado pelo programa como texto coloca uma barra invertida antes
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          //exibe a mensagem carregando enquanto estiver pegando os dados da api
          future: getData(), //pega o futuro e passa para o futureBuilder
          builder: (contexto, snapshot) {
            //contexto e foto dos dados que obter
            switch (snapshot.connectionState) {
              //veerifica o estado da conexao, snapshot eh 'fotos' do estado dos dados
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, //alarga tudo no tam da tela
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextField("Reais", "R\$",realController,_realChanged),
                          Divider(), //espaco entre um elemento e outro
                          buildTextField("Doláres", "US\$",dolarController,_dolarChanged),
                          Divider(),
                          buildTextField("Euros", "€",euroController,_euroChanged),
                        ],
                      ));
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefixo, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(), //borda
        prefixText: prefixo),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f, //quando mudar o campo, ele chama essa funcao
    keyboardType: TextInputType.number,
  );
}
