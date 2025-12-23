
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B7BFF),
        toolbarHeight: 80,
        centerTitle: true,
        title: Text(
          'about'.tr(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                const Text(
                  "📱 الوصف العام للتطبيق",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7BFF),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "تطبيق Transport Assistant هو تطبيق مخصص لتسهيل التنقل داخل المدن الجزائرية، حيث يهدف إلى مساعدة المواطنين والطلبة على استخدام وسائل النقل الحضري بذكاء وسهولة.\n\n"
                      "يدعم التطبيق المدن الكبرى مثل الجزائر العاصمة، وهران، قسنطينة، وسيدي بلعباس، ويعتمد على واجهة خرائط تفاعلية (Google Maps API) لعرض الخطوط، المحطات، والاتجاهات في الزمن الحقيقي.\n\n"
                      "يوفر التطبيق ميزات ذكية تساعد المستخدم على اختيار أفضل طريق وأقرب محطة انطلاق بناءً على موقعه الحالي.",
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                const Text(
                  "🎯 أهداف التطبيق",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7BFF),
                  ),
                ),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("مساعدة المواطنين والطلبة على التنقل بسهولة وسرعة داخل المدن."),
                ),
                const ListTile(
                  leading: Icon(Icons.map, color: Colors.orange),
                  title: Text("عرض الخطوط والمسارات بدقة على الخريطة بطريقة تفاعلية."),
                ),
                const ListTile(
                  leading: Icon(Icons.location_on, color: Colors.redAccent),
                  title: Text("تقديم معلومات فورية حول المحطات، المسافات، ومدة الرحلة التقديرية."),
                ),
                const ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blueGrey),
                  title: Text("تقليل الوقت الضائع في البحث عن الاتجاه الصحيح أو أقرب محطة ترامواي أو حافلة."),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
