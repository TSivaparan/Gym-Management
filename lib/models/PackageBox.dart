
class PackageBox {
  final String duration;
  final String packageId;

  const PackageBox({
    required this.duration,
    required this.packageId,
  });
}


//   Future<void> addPackageToFirestore(String packageId) async {
//     final CollectionReference packagesRef =
//     FirebaseFirestore.instance.collection('packages');
//     final DocumentSnapshot packageDoc = await packagesRef.doc(packageId).get();
//
//     if (packageDoc.exists) {
//       // Package already exists, perform desired actions
//       // For example, show a message that the package is already added
//       print('Package already added.');
//     } else {
//       // Package does not exist, add it to Firestore
//       await packagesRef.doc(packageId).set({
//         'duration': duration,
//       });
//       // Perform any additional actions upon successful addition
//       // For example, show a success message
//       print('Package added successfully!');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double borderRadius = screenWidth * 0.02; // Adjust the factor for desired border radius
//
//     return Container(
//       width: screenWidth,
//       height: 200,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: shadowColor,
//             offset: Offset(0, 3),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             duration,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () => addPackageToFirestore(packageId),
//             child: Text('Add'),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
