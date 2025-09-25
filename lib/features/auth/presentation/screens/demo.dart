// // Automatic FlutterFlow imports
// import '/backend/schema/structs/index.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/widgets/index.dart'; // Imports other custom widgets
// import '/custom_code/actions/index.dart'; // Imports custom actions
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// import 'package:flutter/material.dart';
// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// // Extra imports
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math' as math; // required for GradientRotation

// // Import your confirm tray widget
// import '/popup/confirm_tray/confirm_tray_widget.dart';

// class Paginatedlistviewbial extends StatefulWidget {
//   Paginatedlistviewbial({
//     super.key,
//     this.width,
//     this.height,
//     this.dividers = 0,
//   });

//   final double? width;
//   final double? height;
//   final int dividers;

//   @override
//   State<Paginatedlistviewbial> createState() => _PaginatedlistviewbialState();
// }

// class _PaginatedlistviewbialState extends State<Paginatedlistviewbial> {
//   List<dynamic> trays = [];
//   int offset = 0;
//   bool isLoading = false;
//   bool hasMore = true;
//   int? selectedDivider;

//   // Static token
//   final String staticToken =
//       "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2wiOiJhZG1pbiIsImV4cCI6MTkwMDY1MzE0M30.asYhgMAOvrau4G6LI4V4IbgYZ022g_GX0qZxaS57GQc";

//   @override
//   void initState() {
//     super.initState();
//     selectedDivider = widget.dividers;
//     fetchTrays(reset: true);
//   }

//   Future<void> fetchTrays({bool reset = false}) async {
//     if (isLoading || (!hasMore && !reset)) return;

//     if (reset) {
//       setState(() {
//         trays = [];
//         offset = 0;
//         hasMore = true;
//       });
//     }

//     setState(() => isLoading = true);

//     final token = staticToken;

//     final url =
//         "https://bialinternal.leapmile.com/nanostore/trays_for_order?order_type=inbound&offset=$offset&num_records=10&tray_height=${selectedDivider ?? 0}&has_item=false";

//     try {
//       final response = await http.get(Uri.parse(url), headers: {
//         "accept": "application/json",
//         "Authorization": "Bearer $token",
//       });

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List newTrays = data["records"];

//         setState(() {
//           offset += 10;
//           if (newTrays.isEmpty || newTrays.length < 10) {
//             hasMore = false;
//           }
//           trays.addAll(newTrays);
//         });
//       } else {
//         debugPrint("❌ API error: ${response.statusCode}");
//         setState(() {
//           hasMore = false;
//           trays = [];
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching trays: $e");
//       setState(() {
//         hasMore = false;
//         trays = [];
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   /// Card design
//   Widget trayCard({
//     required String trayId,
//     required String quantity,
//     required String height,
//     required String updated,
//     required String weight,
//     required VoidCallback onRequest,
//   }) {
//     final TextStyle keyStyle = const TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w400,
//       color: Color(0xFFA4A5A5),
//       height: 1.5,
//     );

//     final TextStyle valueStyle = const TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w500,
//       color: Colors.black,
//       height: 1.5,
//     );

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       // padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0xFFE0E3E7),
//             offset: Offset(0, 2.5),
//           ),
//         ],
//         // all shadows removed as requested
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Gradient wrapper for the top row
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 10, vertical: 10), // horizontal & vertical gap = 10
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: const [
//                   Color(0xFFE1EFEF),
//                   Color(0xFFFFFFFF),
//                 ],
//                 stops: const [0.0, 1.0],
//                 // use transform to make it exactly 90 degrees
//                 transform: GradientRotation(math.pi / 2),
//               ),
//               // only top-left and top-right corners rounded 10 px
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   height: 30,
//                   margin: const EdgeInsets.only(right: 10),
//                   child: Image.asset(
//                     'assets/images/binwithtray.png',
//                     height: 30,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Expanded(
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(text: "Tray Id: ", style: keyStyle),
//                         TextSpan(text: trayId, style: valueStyle),
//                       ],
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A8181),
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(80, 36),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   ).copyWith(
//                     side: MaterialStateProperty.all(BorderSide.none),
//                   ),
//                   onPressed: onRequest,
//                   child: const Text(
//                     "Request",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 1,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(text: "Quantity: ", style: keyStyle),
//                       TextSpan(text: quantity, style: valueStyle),
//                     ],
//                   ),
//                 ),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(text: "Height: ", style: keyStyle),
//                       TextSpan(text: height, style: valueStyle),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(text: "Updated: ", style: keyStyle),
//                       TextSpan(text: updated, style: valueStyle),
//                     ],
//                   ),
//                 ),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(text: "Weight: ", style: keyStyle),
//                       TextSpan(text: weight, style: valueStyle),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Open Confirm Tray bottom sheet
//   void _openConfirmTray(BuildContext context, dynamic tray) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (sheetContext) {
//         return GestureDetector(
//           onTap: () {
//             FocusScope.of(sheetContext).unfocus();
//             FocusManager.instance.primaryFocus?.unfocus();
//           },
//           child: Padding(
//             padding: MediaQuery.of(sheetContext).viewInsets,
//             child: ConfirmTrayWidget(
//               trayid: tray["tray_id"].toString(),
//               qyts: tray["available_quantity"]?.toInt() ?? "N/A",
//               division: tray["tray_divider"]?.toInt() ?? "0",
//               weight: tray["tray_weight"]?.toInt() ?? "0",
//               update: changeformate(
//                 tray["updated_at"]?.toString() ?? "",
//               )!,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.92, // 92% width
//         constraints: const BoxConstraints(maxWidth: 420), // max-width = 420
//         height: widget.height ?? double.infinity,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//         ),
//         child: Column(
//           children: [
//             // Header with Tray Height + Dropdown (NO bottom border)
//             Container(
//               padding: const EdgeInsets.only(top: 10),
//               decoration: const BoxDecoration(
//                 color: Colors.white, // no bottom border
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Tray Height",
//                     style: TextStyle(
//                       fontFamily: "Roboto",
//                       fontWeight: FontWeight.w700,
//                       fontSize: 18,
//                       color: Colors.black,
//                       height: 1.5,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 125,
//                     height: 40,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade400),
//                       ),
//                       child: DropdownButton<int>(
//                         isExpanded: true,
//                         value: selectedDivider,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                           fontFamily: "Roboto",
//                         ),
//                         hint: const Text(
//                           "Select Height",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.black54,
//                           ),
//                         ),
//                         underline: const SizedBox(),
//                         items: const [
//                           DropdownMenuItem(value: 80, child: Text("80")),
//                           DropdownMenuItem(value: 100, child: Text("100")),
//                           DropdownMenuItem(value: 180, child: Text("180")),
//                            DropdownMenuItem(value: 225, child: Text("225")),
//                         ],
//                         onChanged: (val) {
//                           setState(() => selectedDivider = val);
//                           fetchTrays(reset: true);
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// Body
//             Expanded(
//               child: trays.isEmpty && !isLoading
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             'assets/images/nodata.gif',
//                             height: 200,
//                             fit: BoxFit.contain,
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             "No Trays Found",
//                             style: TextStyle(
//                               fontFamily: "Roboto",
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black54,
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : NotificationListener<ScrollNotification>(
//                       onNotification: (scrollInfo) {
//                         if (!isLoading &&
//                             hasMore &&
//                             scrollInfo.metrics.pixels ==
//                                 scrollInfo.metrics.maxScrollExtent) {
//                           fetchTrays();
//                         }
//                         return false;
//                       },
//                       child: ListView.builder(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         itemCount: trays.length + (hasMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index == trays.length) {
//                             return const Padding(
//                               padding: EdgeInsets.all(10),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }

//                           final tray = trays[index];
//                           final trayId = tray["tray_id"]?.toString() ?? "N/A";
//                           final quantity =
//                               tray["quantity"]?.toString() ?? "N/A";
//                           final heightInt = tray["tray_height"] != null
//                               ? int.tryParse(tray["tray_height"].toString())
//                               : null;

//                           String updated = "N/A";
//                           if (tray["updated_at"] != null) {
//                             try {
//                               final parsedDate =
//                                   DateTime.parse(tray["updated_at"].toString());
//                               updated = DateFormat("yyyy-MM-dd HH:mm")
//                                   .format(parsedDate.toLocal());
//                             } catch (e) {
//                               updated = tray["updated_at"].toString();
//                             }
//                           }

//                           final weightGrams = tray["tray_weight"] != null
//                               ? int.tryParse(tray["tray_weight"].toString())
//                               : null;
//                           final weight = (weightGrams != null &&
//                                   weightGrams > 0)
//                               ? "${(weightGrams / 1000).toStringAsFixed(2)} KG"
//                               : "N/A";

//                           return trayCard(
//                             trayId: trayId,
//                             quantity: quantity,
//                             height: (heightInt ?? 0).toString(),
//                             updated: updated,
//                             weight: weight,
//                             onRequest: () => _openConfirmTray(context, tray),
//                           );
//                         },
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }