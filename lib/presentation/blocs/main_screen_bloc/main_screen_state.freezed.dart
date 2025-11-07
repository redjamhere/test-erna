// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainScreenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainScreenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenState()';
}


}

/// @nodoc
class $MainScreenStateCopyWith<$Res>  {
$MainScreenStateCopyWith(MainScreenState _, $Res Function(MainScreenState) __);
}


/// Adds pattern-matching-related methods to [MainScreenState].
extension MainScreenStatePatterns on MainScreenState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( bool hasConnectedDevice,  BluetoothDeviceInfo? connectedDevice,  HeartRateData? heartRate,  StepsData? steps,  BatteryData? battery,  BodyTemperatureData? temperature,  OxygenSaturationData? oxygenSaturation)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.hasConnectedDevice,_that.connectedDevice,_that.heartRate,_that.steps,_that.battery,_that.temperature,_that.oxygenSaturation);case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( bool hasConnectedDevice,  BluetoothDeviceInfo? connectedDevice,  HeartRateData? heartRate,  StepsData? steps,  BatteryData? battery,  BodyTemperatureData? temperature,  OxygenSaturationData? oxygenSaturation)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.hasConnectedDevice,_that.connectedDevice,_that.heartRate,_that.steps,_that.battery,_that.temperature,_that.oxygenSaturation);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( bool hasConnectedDevice,  BluetoothDeviceInfo? connectedDevice,  HeartRateData? heartRate,  StepsData? steps,  BatteryData? battery,  BodyTemperatureData? temperature,  OxygenSaturationData? oxygenSaturation)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.hasConnectedDevice,_that.connectedDevice,_that.heartRate,_that.steps,_that.battery,_that.temperature,_that.oxygenSaturation);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements MainScreenState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenState.initial()';
}


}




/// @nodoc


class _Loading implements MainScreenState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenState.loading()';
}


}




/// @nodoc


class _Loaded implements MainScreenState {
  const _Loaded({required this.hasConnectedDevice, this.connectedDevice, this.heartRate, this.steps, this.battery, this.temperature, this.oxygenSaturation});
  

 final  bool hasConnectedDevice;
 final  BluetoothDeviceInfo? connectedDevice;
 final  HeartRateData? heartRate;
 final  StepsData? steps;
 final  BatteryData? battery;
 final  BodyTemperatureData? temperature;
 final  OxygenSaturationData? oxygenSaturation;

/// Create a copy of MainScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.hasConnectedDevice, hasConnectedDevice) || other.hasConnectedDevice == hasConnectedDevice)&&(identical(other.connectedDevice, connectedDevice) || other.connectedDevice == connectedDevice)&&(identical(other.heartRate, heartRate) || other.heartRate == heartRate)&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.battery, battery) || other.battery == battery)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.oxygenSaturation, oxygenSaturation) || other.oxygenSaturation == oxygenSaturation));
}


@override
int get hashCode => Object.hash(runtimeType,hasConnectedDevice,connectedDevice,heartRate,steps,battery,temperature,oxygenSaturation);

@override
String toString() {
  return 'MainScreenState.loaded(hasConnectedDevice: $hasConnectedDevice, connectedDevice: $connectedDevice, heartRate: $heartRate, steps: $steps, battery: $battery, temperature: $temperature, oxygenSaturation: $oxygenSaturation)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $MainScreenStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 bool hasConnectedDevice, BluetoothDeviceInfo? connectedDevice, HeartRateData? heartRate, StepsData? steps, BatteryData? battery, BodyTemperatureData? temperature, OxygenSaturationData? oxygenSaturation
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of MainScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hasConnectedDevice = null,Object? connectedDevice = freezed,Object? heartRate = freezed,Object? steps = freezed,Object? battery = freezed,Object? temperature = freezed,Object? oxygenSaturation = freezed,}) {
  return _then(_Loaded(
hasConnectedDevice: null == hasConnectedDevice ? _self.hasConnectedDevice : hasConnectedDevice // ignore: cast_nullable_to_non_nullable
as bool,connectedDevice: freezed == connectedDevice ? _self.connectedDevice : connectedDevice // ignore: cast_nullable_to_non_nullable
as BluetoothDeviceInfo?,heartRate: freezed == heartRate ? _self.heartRate : heartRate // ignore: cast_nullable_to_non_nullable
as HeartRateData?,steps: freezed == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as StepsData?,battery: freezed == battery ? _self.battery : battery // ignore: cast_nullable_to_non_nullable
as BatteryData?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as BodyTemperatureData?,oxygenSaturation: freezed == oxygenSaturation ? _self.oxygenSaturation : oxygenSaturation // ignore: cast_nullable_to_non_nullable
as OxygenSaturationData?,
  ));
}


}

/// @nodoc


class _Error implements MainScreenState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of MainScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MainScreenState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MainScreenStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of MainScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
