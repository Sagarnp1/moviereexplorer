// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_movie.dart';



class FavoriteMovieAdapter extends TypeAdapter<FavoriteMovie> {
  @override
  final int typeId = 0;

  @override
  FavoriteMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String,
      releaseDate: fields[3] as String,
      voteAverage: fields[4] as double,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMovie obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.voteAverage)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
