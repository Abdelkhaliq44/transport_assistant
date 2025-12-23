import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Sittinges extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDark;
  const Sittinges({super.key, this.onThemeChanged, required this.isDark, });

  @override
  State<Sittinges> createState() => _SittingesState();
}

class _SittingesState extends State<Sittinges> {
  late bool _isDark;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isDark = widget.isDark;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff4b7bff),
        toolbarHeight: 80,
        centerTitle: true,
        title: Text('settings'.tr(),style: TextStyle(fontSize: 30,),),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18,50,18,18),
          children: [
      Card(
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
        color: Color(0xffFFA726),
    child:ListTile(
      trailing: Switch(
          value: _isDark,
    onChanged: ( value) {
    setState(()=>_isDark=value );
    widget.onThemeChanged?.call(value);}
    ),
        title:  Padding(
      padding: const EdgeInsets.all(18.0),
      child: Text('dark_light_mode'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black87,),),
    ),
    ),
    ),
            SizedBox(height: 18,),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Color(0xffFFA726),
              child:ListTile(
                trailing:DropdownButton(
                  value: context.locale.languageCode,
                  items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
                        Text('English'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: Row(
                      children: [
                        Text('🇸🇦 ', style: TextStyle(fontSize: 20)),
                        Text('العربية'),
                      ],
                    ),
                  ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Row(
                        children: [
                          Text('🇫🇷 ', style: TextStyle(fontSize: 20)),
                          Text('Français'),
                        ],
                      ),
                    ),
                ],
                  icon: const Icon(Icons.language, color: Colors.blue),
                  underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    EasyLocalization.of(context)!.setLocale(Locale(newValue)); // تغيير اللغة
                    setState(() {});
                  }
                },
                ),
                title:  Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text('language'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black87,),),
                ),
              ),
            ),
          ],
      ),
    );
  }
}
