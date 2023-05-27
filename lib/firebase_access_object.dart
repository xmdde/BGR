import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameTakenExeption implements Exception {}

class RecordNotFoundExeption implements Exception {}

class FirebaseDAO {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _boardGames =
      FirebaseFirestore.instance.collection('board_games');
  final CollectionReference _ratings =
      FirebaseFirestore.instance.collection('ratings');

  Future<void> postUser(String username, String password) async {
    final docRef = _users.doc(username).withConverter(
          fromFirestore: UserDataObject.fromFirestore,
          toFirestore: (UserDataObject user, _) => user.toFirestore(),
        );

    final docSnap = await docRef.get();
    final user = docSnap.data();

    if (user != null) {
      throw UsernameTakenExeption();
    } else {
      return _users.doc(username).set({
        'username': username,
        'password': password,
      });
    }
  }

  Future<UserDataObject> getUserByUsername(String username) async {
    final docRef = _users.doc(username).withConverter(
          fromFirestore: UserDataObject.fromFirestore,
          toFirestore: (UserDataObject user, _) => user.toFirestore(),
        );

    final docSnap = await docRef.get();
    final user = docSnap.data();

    if (user != null) {
      return user;
    } else {
      throw RecordNotFoundExeption();
    }
  }

  Future<List<UserDataObject>> getUsers() async {
    var users = <UserDataObject>[];
    final usersRef = _users.withConverter(
      fromFirestore: UserDataObject.fromFirestore,
      toFirestore: (UserDataObject user, _) => user.toFirestore(),
    );

    QuerySnapshot querySnapshot = await usersRef.get();
    users = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<UserDataObject>()
        .toList();
    return users;
  }

  Future<bool> authUser(String username, String password) async {
    final docRef = _users.doc(username).withConverter(
          fromFirestore: UserDataObject.fromFirestore,
          toFirestore: (UserDataObject user, _) => user.toFirestore(),
        );

    final docSnap = await docRef.get();
    final user = docSnap.data();

    if (user != null) {
      return user.password == password;
    } else {
      throw RecordNotFoundExeption();
    }
  }

  Future<void> postBoardGame(String title, String description, String genre,
      double rating, String img) async {
    List<String> ids = <String>[];
    final ratingsRef = _ratings.where("title", isEqualTo: title).withConverter(
          fromFirestore: RatingDataObject.fromFirestore,
          toFirestore: (RatingDataObject rating, _) => rating.toFirestore(),
        );
    QuerySnapshot<RatingDataObject> querySnapshot = await ratingsRef.get();
    ids = querySnapshot.docs.map((doc) => doc.id).toList();
    var id = ids.elementAtOrNull(0);
    if (id != null) {
      return _boardGames.doc(id).set({
        'title': title,
        'description': description,
        'genre': genre,
        'rating': rating,
        'img': img,
      });
    } else {
      return _boardGames.add({
        'title': title,
        'description': description,
        'genre': genre,
        'rating': rating,
        'img': img,
      }).ignore();
    }
  }

  Future<BoardGameDataObject?> getBoardGameByTitle(String title) async {
    List<BoardGameDataObject> boardGames = <BoardGameDataObject>[];
    final boardGamesRef =
        _boardGames.where("title", isEqualTo: title).withConverter(
              fromFirestore: BoardGameDataObject.fromFirestore,
              toFirestore: (BoardGameDataObject boardGame, _) =>
                  boardGame.toFirestore(),
            );

    QuerySnapshot querySnapshot = await boardGamesRef.get();
    boardGames = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<BoardGameDataObject>()
        .toList();
    return boardGames[0];
  }

  Future<List<BoardGameDataObject>> getBoardGames() async {
    List<BoardGameDataObject> boardGames = <BoardGameDataObject>[];
    final boardGamesRef = _boardGames.withConverter(
      fromFirestore: BoardGameDataObject.fromFirestore,
      toFirestore: (BoardGameDataObject boardGame, _) =>
          boardGame.toFirestore(),
    );

    QuerySnapshot querySnapshot = await boardGamesRef.get();
    boardGames = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<BoardGameDataObject>()
        .toList();
    return boardGames;
  }

  Future<List<RatingDataObject>> getRatings() async {
    List<RatingDataObject> ratings = <RatingDataObject>[];
    final ratingsRef = _ratings.withConverter(
      fromFirestore: RatingDataObject.fromFirestore,
      toFirestore: (RatingDataObject rating, _) => rating.toFirestore(),
    );

    QuerySnapshot querySnapshot = await ratingsRef.get();
    ratings = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<RatingDataObject>()
        .toList();
    return ratings;
  }

  Future<List<RatingDataObject>> getRatingsByUsername(String username) async {
    List<RatingDataObject> ratings = <RatingDataObject>[];
    final ratingsRef =
        _ratings.where("username", isEqualTo: username).withConverter(
              fromFirestore: RatingDataObject.fromFirestore,
              toFirestore: (RatingDataObject rating, _) => rating.toFirestore(),
            );

    QuerySnapshot querySnapshot = await ratingsRef.get();
    ratings = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<RatingDataObject>()
        .toList();
    return ratings;
  }

  Future<List<RatingDataObject>> getRatingsByTitle(String title) async {
    List<RatingDataObject> ratings = <RatingDataObject>[];
    final ratingsRef = _ratings.where("title", isEqualTo: title).withConverter(
          fromFirestore: RatingDataObject.fromFirestore,
          toFirestore: (RatingDataObject rating, _) => rating.toFirestore(),
        );

    QuerySnapshot querySnapshot = await ratingsRef.get();
    ratings = querySnapshot.docs
        .map((doc) => doc.data())
        .cast<RatingDataObject>()
        .toList();
    return ratings;
  }

  Future<void> postRating(
      String title, String username, double rating, bool fav) async {
    List<String> ids = <String>[];
    final ratingsRef = _ratings.where("title", isEqualTo: title).withConverter(
          fromFirestore: RatingDataObject.fromFirestore,
          toFirestore: (RatingDataObject rating, _) => rating.toFirestore(),
        );
    QuerySnapshot<RatingDataObject> querySnapshot = await ratingsRef.get();
    ids = querySnapshot.docs
        .where((doc) => doc.data().username == username)
        .map((doc) => doc.id)
        .toList();
    var id = ids.elementAtOrNull(0);
    if (id != null) {
      return _ratings.doc(id).set({
        'title': title,
        'username': username,
        'rating': rating,
        'fav': fav,
      });
    } else {
      return _ratings.add({
        "title": title,
        "username": username,
        "rating": rating,
        'fav': fav,
      }).ignore();
    }
  }
}

class UserDataObject {
  final String? username;
  final String? password;

  UserDataObject({this.username, this.password});

  factory UserDataObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserDataObject(
      username: data?['username'],
      password: data?['password'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (username != null) "name": username,
      if (password != null) "decription": password
    };
  }
}

class BoardGameDataObject {
  final String? title;
  final String? description;
  final String? genre;
  final num? rating;
  final String? img;

  BoardGameDataObject(
      {this.title, this.description, this.genre, this.rating, this.img});

  factory BoardGameDataObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return BoardGameDataObject(
      title: data?['title'],
      description: data?['description'],
      genre: data?['genre'],
      rating: data?['rating'],
      img: data?['img'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (description != null) "description": description,
      if (genre != null) "genre": genre,
      if (rating != null) "title": rating,
      if (img != null) "img": img,
    };
  }
}

class RatingDataObject {
  final String? title;
  final String? username;
  final num? rating;
  final bool? fav;

  RatingDataObject({this.title, this.username, this.rating, this.fav});

  factory RatingDataObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return RatingDataObject(
      title: data?['title'],
      username: data?['username'],
      rating: data?['rating'],
      fav: data?['fav'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (username != null) "username": username,
      if (rating != null) "rating": rating,
      if (fav != null) "fav": fav,
    };
  }
}
