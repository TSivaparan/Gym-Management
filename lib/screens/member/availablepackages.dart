import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/PackageBox.dart';



// class AvailablePackagePage extends StatelessWidget {
//   final duration, packageId, color;
//
//   AvailablePackagePage({this.duration,this.packageId, this.color});
//
//
//   @override
//   Widget build(BuildContext context) {
//     Color boxColor=color;
//
//     return  Padding(
//       padding: EdgeInsets.symmetric(horizontal: 10),
//       child: PackageBox(
//         duration: duration,
//         backgroundColor: boxColor,
//         shadowColor: Colors.blue.withOpacity(0.6),
//         packageId: packageId,
//       ),
//

        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        //   child: PackageBox(
        //     duration: '6 Months',
        //     backgroundColor: Colors.red,
        //     shadowColor: Colors.red.withOpacity(0.6),
        //     packageId: 'package_2',
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 10),
        //   child: PackageBox(
        //     duration: '4 Months',
        //     backgroundColor: Colors.green,
        //     shadowColor: Colors.green.withOpacity(0.6),
        //     packageId: 'package_3',
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        //   child: PackageBox(
        //     duration: '1 Year',
        //     backgroundColor: Colors.orange,
        //     shadowColor: Colors.orange.withOpacity(0.6),
        //     packageId: 'package_4',
        //   ),
//         // ),
//     );
//   }
// }
//
