import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class BussRequestHandler {
  Future<Response> handleGetWalletById(ObjectId id);
  Future<Response> handleBussTransfer({
    required ObjectId senderId,
    required ObjectId receiverId,
    required double amount,
    required String description,
  });
}

class BussRequestHandlerImpl implements BussRequestHandler {
  final BussRepository _bussRepository;

  BussRequestHandlerImpl({
    required BussRepository bussRepository,
  }) : _bussRepository = bussRepository;

  @override
  Future<Response> handleGetWalletById(ObjectId id) async {
    final wallet = await _bussRepository.getWalletById(id);
    return Response.json(body: wallet);
  }

  @override
  Future<Response> handleBussTransfer({
    required ObjectId senderId,
    required ObjectId receiverId,
    required double amount,
    required String description,
  }) async {
    if (senderId == receiverId) {
      return Response(
        body: 'Sender and receiver cannot be the same',
        statusCode: 400,
      );
    }

    final senderWallet = await _bussRepository.getWalletById(senderId);
    if (senderWallet.balance < amount) {
      return Response.json(
        body: 'Insufficient funds',
        statusCode: 400,
      );
    }

    final transaction = await _bussRepository.bussTransfer(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      description: description,
    );
    return Response.json(body: transaction);
  }
}
