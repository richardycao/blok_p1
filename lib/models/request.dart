import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String requestId;
  String type;
  String itemId;
  String requesterId;
  Map<String, String> approvers;
  int requiredApprovals;
  Map<String, int> responses;
  String message;
  DateTime createDate;

  Request(
      {this.requestId,
      this.type,
      this.itemId,
      this.requesterId,
      this.approvers,
      this.requiredApprovals,
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
      approvers: Map<String, String>.from(data['approvers']) ?? {},
      requiredApprovals: data['requiredApprovals'] as int ?? null,
      responses: Map<String, int>.from(data['responses']) ?? {},
      message: data['message'] as String ?? null,
      createDate: data['createDate'].toDate() as DateTime ?? null,
    );
  }
}
