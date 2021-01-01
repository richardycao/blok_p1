import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String requestId;
  String type;
  String itemId;
  String requesterId;
  String requesterName;
  Map<String, String> ownerApprovers;
  Map<String, String> otherApprovers;
  bool hasOwnerApproval;
  bool hasOtherApproval;
  Map<String, int> responses;
  String message;
  DateTime createDate;

  Request(
      {this.requestId,
      this.type,
      this.itemId,
      this.requesterId,
      this.requesterName,
      this.ownerApprovers,
      this.otherApprovers,
      this.hasOwnerApproval,
      this.hasOtherApproval,
      this.responses,
      this.message,
      this.createDate});

  factory Request.fromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data;
    data = data ?? {};
    return Request(
      requestId: snapshot.documentID ?? null,
      type: data['type'] as String ?? null,
      itemId: data['itemId'] as String ?? null,
      requesterId: data['requesterId'] as String ?? null,
      requesterName: data['requesterName'] as String ?? null,
      ownerApprovers: Map<String, String>.from(data['ownerApprovers']) ?? {},
      otherApprovers: Map<String, String>.from(data['otherApprovers']) ?? {},
      hasOwnerApproval: data['hasOwnerApproval'] as bool ?? null,
      hasOtherApproval: data['hasOtherApproval'] as bool ?? null,
      responses: Map<String, int>.from(data['responses']) ?? {},
      message: data['message'] as String ?? null,
      createDate: data['createDate'].toDate() as DateTime ?? null,
    );
  }
}
