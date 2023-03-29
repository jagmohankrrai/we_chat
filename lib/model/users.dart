class users{
  String? uid;
  String? full_name;String? email;String? dp;
  users({
    this.uid,
    this.full_name,
    this.email,
    this.dp
}
      );
  users.fromMap(Map<String,dynamic>map){
    uid = map["uid"];
    full_name = map["full_name"];
    email = map["email"];
    dp = map["dp"];
  }
  Map<String,dynamic>toMap()
  {
    return
        {
          "uid":uid,
          "full_name":full_name,
          "email":email,
          "dp":dp,
        };
  }
}