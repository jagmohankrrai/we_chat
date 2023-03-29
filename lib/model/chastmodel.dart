class chastmodel{
  String? roomid;
  Map<String, dynamic>? prticipents;
  String? lastmsg;
  chastmodel(
  {
    this.roomid,
    this.lastmsg,
    this.prticipents,
}
      );
  chastmodel.fromMap(Map<String,dynamic>map){
    roomid=map["roomid"];
    lastmsg=map["lastmsg"];
    prticipents=map["prticipents"];
  }
  Map<String,dynamic>toMap()
  {
    return
      {
        "roomid":roomid,
        "lastmsg":lastmsg,
        "prticipents":prticipents,
      };
  }
}