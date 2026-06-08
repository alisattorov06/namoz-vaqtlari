// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_time_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimeAdapter extends TypeAdapter<PrayerTime> {
  @override
  final int typeId = 0;

  @override
  PrayerTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTime(
      date: fields[0] as String,
      fajr: fields[1] as String,
      sunrise: fields[2] as String,
      dhuhr: fields[3] as String,
      asr: fields[4] as String,
      maghrib: fields[5] as String,
      isha: fields[6] as String,
      hijriDay: fields[7] as String,
      hijriMonth: fields[8] as String,
      hijriYear: fields[9] as String,
      hijriMonthAr: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTime obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.fajr)
      ..writeByte(2)
      ..write(obj.sunrise)
      ..writeByte(3)
      ..write(obj.dhuhr)
      ..writeByte(4)
      ..write(obj.asr)
      ..writeByte(5)
      ..write(obj.maghrib)
      ..writeByte(6)
      ..write(obj.isha)
      ..writeByte(7)
      ..write(obj.hijriDay)
      ..writeByte(8)
      ..write(obj.hijriMonth)
      ..writeByte(9)
      ..write(obj.hijriYear)
      ..writeByte(10)
      ..write(obj.hijriMonthAr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
