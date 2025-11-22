class PostDetailsModel {
  int? id;
  String? title;
  String? body;
  List<String>? tags;
  Reactions? reactions;
  int? views;
  int? userId;

  PostDetailsModel(
      {this.id,
      this.title,
      this.body,
      this.tags,
      this.reactions,
      this.views,
      this.userId});

  PostDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    tags = json['tags'].cast<String>();
    reactions = json['reactions'] != null
        ? new Reactions.fromJson(json['reactions'])
        : null;
    views = json['views'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    data['tags'] = tags;
    if (reactions != null) {
      data['reactions'] = reactions!.toJson();
    }
    data['views'] = views;
    data['userId'] = userId;
    return data;
  }
}

class Reactions {
  int? likes;
  int? dislikes;

  Reactions({this.likes, this.dislikes});

  Reactions.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    dislikes = json['dislikes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    return data;
  }
}
