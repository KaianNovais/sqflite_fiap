import 'package:flutter/material.dart';
import 'package:sqflite_crud_fiap/Models/contact.dart';
import 'package:sqflite_crud_fiap/Utils/database.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  Contact _contact = Contact();
  List<Contact> _list = [];
  DatabaseHelper? _databaseHelper;
  final _ctlName = TextEditingController();
  final _ctlMobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _databaseHelper = DatabaseHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _form(),
            _lista(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //formulário de cadastro
  _form() => Container(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ctlName,
                decoration: const InputDecoration(labelText: "Nome"),
                onSaved: (val) => setState(() {
                  _contact.name = val;
                }),
              ),
              TextFormField(
                controller: _ctlMobile,
                decoration: const InputDecoration(labelText: "Mobile"),
                onSaved: (val) => setState(() {
                  _contact.mobile = val;
                }),
              ),
              ElevatedButton(
                onPressed: (){
                  _onSubmit();
                  _refreshContactList();
                },
                child: const Text("Salvar"),
              )
            ],
          ),
        ),
      );

  //enviar dados
  _onSubmit() async {
    var form = _formKey.currentState;
    form!.save();
    if(_contact.id == null){
      return await _databaseHelper!.inserContact(_contact);

    }
    else{
      await _databaseHelper!.updatContact(_contact);
      _contact.id = null;
    }

    _refreshContactList();
    _resetForm();
  }
  _resetForm(){
    setState(() {
      _formKey.currentState!.reset();
      _ctlName.clear();
      _ctlMobile.clear();
      _contact.id = null;
    });
  }

  _lista() => Expanded(
        child: Card(
          margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    onTap: (){
                      setState(() {
                        _contact = _list[index];
                        _ctlName.text = _list[index].name!;
                        _ctlMobile.text = _list[index].mobile!;
                      });
                    },
                    leading: const Icon(Icons.account_circle),
                    title: Text(_list[index].name!),
                    subtitle: Text(_list[index].mobile!),
                    trailing: IconButton(
                      onPressed: ()async {
                        await _databaseHelper!.deleteContact(_list[index].id!);
                        _resetForm();
                        _refreshContactList();
                      },
                      icon: const Icon(Icons.delete_sweep),
                    ),
                  ),
                  const Divider(height: 15, color: Colors.black,),
                ],
              );
            },
          ),
        ),
      );
  _refreshContactList() async {
    List<Contact> x = await _databaseHelper!.fetchContacts();
    setState(() {
      _list = x;
    });
  }
}
