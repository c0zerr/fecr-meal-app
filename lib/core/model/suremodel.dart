class SureModel {
  int? idsureler;
  String? sureadi;
  Null? surearabic;
  int? nuzulsira;
  int? ayetsayisi;
  String? nuzulyeri;
  List<Verses>? verses;
  int? sureCount;

  SureModel(
      {this.idsureler,
      this.sureadi,
      this.surearabic,
      this.nuzulsira,
      this.ayetsayisi,
      this.nuzulyeri,
      this.verses,
      this.sureCount});

  SureModel.fromJson(Map<String, dynamic> json) {
    idsureler = json['idsureler'];
    sureadi = json['sureadi'];
    surearabic = json['surearabic'];
    nuzulsira = json['nuzulsira'];
    ayetsayisi = json['ayetsayisi'];
    nuzulyeri = json['nuzulyeri'];
    if (json['verses'] != null) {
      verses = <Verses>[];
      json['verses'].forEach((v) {
        verses!.add(new Verses.fromJson(v));
      });
    }
    sureCount = json['sureCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idsureler'] = this.idsureler;
    data['sureadi'] = this.sureadi;
    data['surearabic'] = this.surearabic;
    data['nuzulsira'] = this.nuzulsira;
    data['ayetsayisi'] = this.ayetsayisi;
    data['nuzulyeri'] = this.nuzulyeri;
    if (this.verses != null) {
      data['verses'] = this.verses!.map((v) => v.toJson()).toList();
    }
    data['sureCount'] = this.sureCount;
    return data;
  }
}

class Verses {
  int? id;
  int? idnuzul;
  int? idsure;
  int? ayetno;
  String? metin;
  String? meal;
  String? aciklama;
  Null? ayetlercol;
  int? sonrakisure;
  int? sonrakisurenuzul;
  int? sonrakiayet;
  int? oncekisure;
  int? oncekisurenuzul;
  int? oncekiayet;
  int? nuzsironceki;
  int? nuzsirsonraki;
  int? onceki;
  int? sonraki;
  AciklamaPTags? aciklamaPTags;

  Verses(
      {this.id,
      this.idnuzul,
      this.idsure,
      this.ayetno,
      this.metin,
      this.meal,
      this.aciklama,
      this.ayetlercol,
      this.sonrakisure,
      this.sonrakisurenuzul,
      this.sonrakiayet,
      this.oncekisure,
      this.oncekisurenuzul,
      this.oncekiayet,
      this.nuzsironceki,
      this.nuzsirsonraki,
      this.onceki,
      this.sonraki,
      this.aciklamaPTags});

  Verses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idnuzul = json['idnuzul'];
    idsure = json['idsure'];
    ayetno = json['ayetno'];
    metin = json['metin'];
    meal = json['meal'];
    aciklama = json['aciklama'];
    ayetlercol = json['ayetlercol'];
    sonrakisure = json['sonrakisure'];
    sonrakisurenuzul = json['sonrakisurenuzul'];
    sonrakiayet = json['sonrakiayet'];
    oncekisure = json['oncekisure'];
    oncekisurenuzul = json['oncekisurenuzul'];
    oncekiayet = json['oncekiayet'];
    nuzsironceki = json['nuzsironceki'];
    nuzsirsonraki = json['nuzsirsonraki'];
    onceki = json['onceki'];
    sonraki = json['sonraki'];
    aciklamaPTags = json['aciklama_p_tags'] != null
        ? new AciklamaPTags.fromJson(json['aciklama_p_tags'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idnuzul'] = this.idnuzul;
    data['idsure'] = this.idsure;
    data['ayetno'] = this.ayetno;
    data['metin'] = this.metin;
    data['meal'] = this.meal;
    data['aciklama'] = this.aciklama;
    data['ayetlercol'] = this.ayetlercol;
    data['sonrakisure'] = this.sonrakisure;
    data['sonrakisurenuzul'] = this.sonrakisurenuzul;
    data['sonrakiayet'] = this.sonrakiayet;
    data['oncekisure'] = this.oncekisure;
    data['oncekisurenuzul'] = this.oncekisurenuzul;
    data['oncekiayet'] = this.oncekiayet;
    data['nuzsironceki'] = this.nuzsironceki;
    data['nuzsirsonraki'] = this.nuzsirsonraki;
    data['onceki'] = this.onceki;
    data['sonraki'] = this.sonraki;
    if (this.aciklamaPTags != null) {
      data['aciklama_p_tags'] = this.aciklamaPTags!.toJson();
    }
    return data;
  }
}

class AciklamaPTags {
  int? count;
  List<Tags>? tags;

  AciklamaPTags({this.count, this.tags});

  AciklamaPTags.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tags {
  String? number;
  String? content;

  Tags({this.number, this.content});

  Tags.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['content'] = this.content;
    return data;
  }
}
