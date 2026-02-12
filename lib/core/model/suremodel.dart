class SureModel {
  int? idsureler;
  String? sureadi;
  String? surearabic;
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
        verses!.add(Verses.fromJson(v));
      });
    }
    sureCount = json['sureCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idsureler'] = idsureler;
    data['sureadi'] = sureadi;
    data['surearabic'] = surearabic;
    data['nuzulsira'] = nuzulsira;
    data['ayetsayisi'] = ayetsayisi;
    data['nuzulyeri'] = nuzulyeri;
    if (verses != null) {
      data['verses'] = verses!.map((v) => v.toJson()).toList();
    }
    data['sureCount'] = sureCount;
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
  String? ayetlercol;
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
        ? AciklamaPTags.fromJson(json['aciklama_p_tags'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idnuzul'] = idnuzul;
    data['idsure'] = idsure;
    data['ayetno'] = ayetno;
    data['metin'] = metin;
    data['meal'] = meal;
    data['aciklama'] = aciklama;
    data['ayetlercol'] = ayetlercol;
    data['sonrakisure'] = sonrakisure;
    data['sonrakisurenuzul'] = sonrakisurenuzul;
    data['sonrakiayet'] = sonrakiayet;
    data['oncekisure'] = oncekisure;
    data['oncekisurenuzul'] = oncekisurenuzul;
    data['oncekiayet'] = oncekiayet;
    data['nuzsironceki'] = nuzsironceki;
    data['nuzsirsonraki'] = nuzsirsonraki;
    data['onceki'] = onceki;
    data['sonraki'] = sonraki;
    if (aciklamaPTags != null) {
      data['aciklama_p_tags'] = aciklamaPTags!.toJson();
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
        tags!.add(Tags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['content'] = content;
    return data;
  }
}
