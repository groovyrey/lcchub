class Student {
  final String name;
  final String id;
  final String course;
  final String? email;
  final String? address;
  final String? mobile;
  final String? enrollmentDate;
  final String? schoolYear;
  final String? yearLevel;
  final String? semester;
  final String? section;
  final List<ScheduleItem>? schedule;
  final Financials? financials;
  final List<SemesterGrade>? grades;
  final List<ReportLink>? availableReports;
  final List<String>? badges;
  final StudentSettings? settings;

  Student({
    this.name = '',
    this.id = '',
    this.course = '',
    this.email,
    this.address,
    this.mobile,
    this.enrollmentDate,
    this.schoolYear,
    this.yearLevel,
    this.semester,
    this.section,
    this.schedule,
    this.financials,
    this.grades,
    this.availableReports,
    this.badges,
    this.settings,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      course: json['course'] ?? '',
      email: json['email'],
      address: json['address'],
      mobile: json['mobile'],
      enrollmentDate: json['enrollment_date'],
      schoolYear: json['schoolYear'],
      yearLevel: json['yearLevel'],
      semester: json['semester'],
      section: json['section'],
      schedule: (json['schedule'] as List?)?.map((e) => ScheduleItem.fromJson(e)).toList(),
      financials: json['financials'] != null ? Financials.fromJson(json['financials']) : null,
      grades: (json['grades'] as List?)?.map((e) => SemesterGrade.fromJson(e)).toList(),
      availableReports: (json['availableReports'] as List?)?.map((e) => ReportLink.fromJson(e)).toList(),
      badges: (json['badges'] as List?)?.map((e) => e.toString()).toList(),
      settings: json['settings'] != null ? StudentSettings.fromJson(json['settings']) : null,
    );
  }
}

class ScheduleItem {
  final String subject;
  final String description;
  final String section;
  final String units;
  final String time;
  final String room;
  final String? instructor;

  ScheduleItem({
    this.subject = '',
    this.description = '',
    this.section = '',
    this.units = '',
    this.time = '',
    this.room = '',
    this.instructor,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      section: json['section'] ?? '',
      units: json['units'] ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
      instructor: json['instructor'],
    );
  }
}

class Financials {
  final String total;
  final String balance;
  final String? dueToday;
  final List<DueAccount>? dueAccounts;
  final List<Payment>? payments;
  final List<Installment>? installments;
  final List<Adjustment>? adjustments;
  final List<Assessment>? assessment;

  Financials({
    this.total = '0',
    this.balance = '0',
    this.dueToday,
    this.dueAccounts,
    this.payments,
    this.installments,
    this.adjustments,
    this.assessment,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      total: json['total'] ?? '0',
      balance: json['balance'] ?? '0',
      dueToday: json['dueToday'],
      dueAccounts: (json['dueAccounts'] as List?)?.map((e) => DueAccount.fromJson(e)).toList(),
      payments: (json['payments'] as List?)?.map((e) => Payment.fromJson(e)).toList(),
      installments: (json['installments'] as List?)?.map((e) => Installment.fromJson(e)).toList(),
      adjustments: (json['adjustments'] as List?)?.map((e) => Adjustment.fromJson(e)).toList(),
      assessment: (json['assessment'] as List?)?.map((e) => Assessment.fromJson(e)).toList(),
    );
  }
}

class DueAccount {
  final String dueDate;
  final String description;
  final String amount;
  final String paid;
  final String due;

  DueAccount({this.dueDate = '', this.description = '', this.amount = '', this.paid = '', this.due = ''});

  factory DueAccount.fromJson(Map<String, dynamic> json) {
    return DueAccount(
      dueDate: json['dueDate'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? '',
      paid: json['paid'] ?? '',
      due: json['due'] ?? '',
    );
  }
}

class Payment {
  final String date;
  final String reference;
  final String amount;

  Payment({this.date = '', this.reference = '', this.amount = ''});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(date: json['date'] ?? '', reference: json['reference'] ?? '', amount: json['amount'] ?? '');
  }
}

class Installment {
  final String dueDate;
  final String description;
  final String assessed;
  final String outstanding;

  Installment({this.dueDate = '', this.description = '', this.assessed = '', this.outstanding = ''});

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      dueDate: json['dueDate'] ?? '',
      description: json['description'] ?? '',
      assessed: json['assessed'] ?? '',
      outstanding: json['outstanding'] ?? '',
    );
  }
}

class Adjustment {
  final String dueDate;
  final String description;
  final String adjustment;
  final String outstanding;

  Adjustment({this.dueDate = '', this.description = '', this.adjustment = '', this.outstanding = ''});

  factory Adjustment.fromJson(Map<String, dynamic> json) {
    return Adjustment(
      dueDate: json['dueDate'] ?? '',
      description: json['description'] ?? '',
      adjustment: json['adjustment'] ?? '',
      outstanding: json['outstanding'] ?? '',
    );
  }
}

class Assessment {
  final String description;
  final String amount;

  Assessment({this.description = '', this.amount = ''});

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(description: json['description'] ?? '', amount: json['amount'] ?? '');
  }
}

class SubjectGrade {
  final String code;
  final String description;
  final String? section;
  final String grade;
  final String? units;
  final String remarks;

  SubjectGrade({
    this.code = '',
    this.description = '',
    this.section,
    this.grade = '',
    this.units,
    this.remarks = '',
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      section: json['section'],
      grade: json['grade'] ?? '',
      units: json['units'],
      remarks: json['remarks'] ?? '',
    );
  }
}

class SemesterGrade {
  final String semester;
  final List<SubjectGrade> subjects;

  SemesterGrade({this.semester = '', this.subjects = const []});

  factory SemesterGrade.fromJson(Map<String, dynamic> json) {
    return SemesterGrade(
      semester: json['semester'] ?? '',
      subjects: (json['subjects'] as List?)?.map((e) => SubjectGrade.fromJson(e)).toList() ?? [],
    );
  }
}

class ReportLink {
  final String text;
  final String href;

  ReportLink({this.text = '', this.href = ''});

  factory ReportLink.fromJson(Map<String, dynamic> json) {
    return ReportLink(text: json['text'] ?? '', href: json['href'] ?? '');
  }
}

class StudentSettings {
  final bool notifications;
  final bool isPublic;
  final bool showAcademicInfo;

  StudentSettings({this.notifications = true, this.isPublic = true, this.showAcademicInfo = true});

  factory StudentSettings.fromJson(Map<String, dynamic> json) {
    return StudentSettings(
      notifications: json['notifications'] ?? true,
      isPublic: json['isPublic'] ?? true,
      showAcademicInfo: json['showAcademicInfo'] ?? true,
    );
  }
}

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? topic;
  final String? imageUrl;
  final bool isAnonymous;
  final dynamic createdAt;
  final List<String>? likes;
  final int commentCount;
  final Poll? poll;

  CommunityPost({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.content = '',
    this.topic,
    this.imageUrl,
    this.isAnonymous = false,
    this.createdAt,
    this.likes,
    this.commentCount = 0,
    this.poll,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      topic: json['topic'],
      imageUrl: json['imageUrl'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: json['createdAt'],
      likes: (json['likes'] as List?)?.map((e) => e.toString()).toList(),
      commentCount: json['commentCount'] ?? 0,
      poll: json['poll'] != null ? Poll.fromJson(json['poll']) : null,
    );
  }
}

class Poll {
  final String question;
  final List<PollOption> options;

  Poll({this.question = '', this.options = const []});

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes.length);

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      question: json['question'] ?? '',
      options: (json['options'] as List?)?.map((e) => PollOption.fromJson(e)).toList() ?? [],
    );
  }
}

class PollOption {
  final dynamic id;
  final String text;
  final List<String> votes;

  PollOption({this.id, this.text = '', this.votes = const []});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      text: json['text'] ?? '',
      votes: (json['votes'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final dynamic createdAt;

  CommunityComment({
    this.id = '',
    this.postId = '',
    this.userId = '',
    this.userName = '',
    this.content = '',
    this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
    );
  }
}

class CommunityPostsResponse {
  final List<CommunityPost> posts;
  final bool hasMore;
  final int limit;
  final int offset;

  CommunityPostsResponse({
    this.posts = const [],
    this.hasMore = false,
    this.limit = 10,
    this.offset = 0,
  });

  factory CommunityPostsResponse.fromJson(Map<String, dynamic> json) {
    return CommunityPostsResponse(
      posts: (json['posts'] as List?)?.map((e) => CommunityPost.fromJson(e)).toList() ?? [],
      hasMore: json['hasMore'] ?? false,
      limit: json['limit'] ?? 10,
      offset: json['offset'] ?? 0,
    );
  }
}

class PostDetailResponse {
  final CommunityPost? post;
  final List<CommunityComment> comments;

  PostDetailResponse({this.post, this.comments = const []});

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) {
    return PostDetailResponse(
      post: json['post'] != null ? CommunityPost.fromJson(json['post']) : null,
      comments: (json['comments'] as List?)?.map((e) => CommunityComment.fromJson(e)).toList() ?? [],
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final String? status;
  final List<String> tools;

  ChatMessage({
    this.id = '',
    this.role = 'user',
    this.content = '',
    this.status,
    this.tools = const [],
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final String? link;

  AppNotification({
    this.id = '',
    this.title = '',
    this.message = '',
    this.type = 'info',
    this.isRead = false,
    this.createdAt = '',
    this.link,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
      link: json['link'],
    );
  }
}
