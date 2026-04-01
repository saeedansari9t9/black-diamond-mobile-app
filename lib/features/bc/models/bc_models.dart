class BcDashboardModel {
  final int totalMembers;
  final num totalPot;
  final num monthlyContribution;
  final int totalMonths;
  final List<String> winnersIds;

  BcDashboardModel({
    required this.totalMembers,
    required this.totalPot,
    required this.monthlyContribution,
    required this.totalMonths,
    required this.winnersIds,
  });

  factory BcDashboardModel.fromJson(Map<String, dynamic> json) {
    return BcDashboardModel(
      totalMembers: json['totalMembers'] ?? 0,
      totalPot: json['totalPot'] ?? 0,
      monthlyContribution: json['monthlyContribution'] ?? 0,
      totalMonths: json['totalMonths'] ?? 0,
      winnersIds: List<String>.from(json['winnersIds'] ?? []),
    );
  }
}

class BcMemberModel {
  final String id;
  final String name;
  final String? phone;

  BcMemberModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory BcMemberModel.fromJson(Map<String, dynamic> json) {
    return BcMemberModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}

class BcMonthState {
  final bool isCompleted;
  final BcMemberModel? winner;

  BcMonthState({
    required this.isCompleted,
    this.winner,
  });

  factory BcMonthState.fromJson(Map<String, dynamic> json) {
    return BcMonthState(
      isCompleted: json['isCompleted'] ?? false,
      winner: json['winner'] != null && (json['winner'] is Map) 
          ? BcMemberModel.fromJson(json['winner']) 
          : null,
    );
  }
}

class BcRecordModel {
  final String id;
  final BcMemberModel member;
  final num amount;
  final bool hasPaid;

  BcRecordModel({
    required this.id,
    required this.member,
    required this.amount,
    required this.hasPaid,
  });

  factory BcRecordModel.fromJson(Map<String, dynamic> json) {
    return BcRecordModel(
      id: json['_id'] ?? '',
      member: BcMemberModel.fromJson(json['member'] ?? {}),
      amount: json['amount'] ?? 0,
      hasPaid: json['hasPaid'] ?? false,
    );
  }
}

class BcMonthDataModel {
  final BcMonthState monthState;
  final List<BcRecordModel> records;
  final num collectedAmount;

  BcMonthDataModel({
    required this.monthState,
    required this.records,
    required this.collectedAmount,
  });

  factory BcMonthDataModel.fromJson(Map<String, dynamic> json) {
    return BcMonthDataModel(
      monthState: BcMonthState.fromJson(json['monthState'] ?? {}),
      records: (json['records'] as List?)
              ?.map((e) => BcRecordModel.fromJson(e))
              .toList() ??
          [],
      collectedAmount: json['collectedAmount'] ?? 0,
    );
  }
}
