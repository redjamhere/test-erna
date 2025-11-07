// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_screen_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainScreenEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainScreenEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent()';
}


}

/// @nodoc
class $MainScreenEventCopyWith<$Res>  {
$MainScreenEventCopyWith(MainScreenEvent _, $Res Function(MainScreenEvent) __);
}


/// Adds pattern-matching-related methods to [MainScreenEvent].
extension MainScreenEventPatterns on MainScreenEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _ConnectToDevice value)?  connectToDevice,TResult Function( _DisconnectFromDevice value)?  disconnectFromDevice,TResult Function( _RefreshData value)?  refreshData,TResult Function( _StartScan value)?  startScan,TResult Function( _StopScan value)?  stopScan,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _ConnectToDevice() when connectToDevice != null:
return connectToDevice(_that);case _DisconnectFromDevice() when disconnectFromDevice != null:
return disconnectFromDevice(_that);case _RefreshData() when refreshData != null:
return refreshData(_that);case _StartScan() when startScan != null:
return startScan(_that);case _StopScan() when stopScan != null:
return stopScan(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _ConnectToDevice value)  connectToDevice,required TResult Function( _DisconnectFromDevice value)  disconnectFromDevice,required TResult Function( _RefreshData value)  refreshData,required TResult Function( _StartScan value)  startScan,required TResult Function( _StopScan value)  stopScan,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _ConnectToDevice():
return connectToDevice(_that);case _DisconnectFromDevice():
return disconnectFromDevice(_that);case _RefreshData():
return refreshData(_that);case _StartScan():
return startScan(_that);case _StopScan():
return stopScan(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _ConnectToDevice value)?  connectToDevice,TResult? Function( _DisconnectFromDevice value)?  disconnectFromDevice,TResult? Function( _RefreshData value)?  refreshData,TResult? Function( _StartScan value)?  startScan,TResult? Function( _StopScan value)?  stopScan,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _ConnectToDevice() when connectToDevice != null:
return connectToDevice(_that);case _DisconnectFromDevice() when disconnectFromDevice != null:
return disconnectFromDevice(_that);case _RefreshData() when refreshData != null:
return refreshData(_that);case _StartScan() when startScan != null:
return startScan(_that);case _StopScan() when stopScan != null:
return stopScan(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( BluetoothDeviceInfo device)?  connectToDevice,TResult Function()?  disconnectFromDevice,TResult Function()?  refreshData,TResult Function()?  startScan,TResult Function()?  stopScan,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _ConnectToDevice() when connectToDevice != null:
return connectToDevice(_that.device);case _DisconnectFromDevice() when disconnectFromDevice != null:
return disconnectFromDevice();case _RefreshData() when refreshData != null:
return refreshData();case _StartScan() when startScan != null:
return startScan();case _StopScan() when stopScan != null:
return stopScan();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( BluetoothDeviceInfo device)  connectToDevice,required TResult Function()  disconnectFromDevice,required TResult Function()  refreshData,required TResult Function()  startScan,required TResult Function()  stopScan,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _ConnectToDevice():
return connectToDevice(_that.device);case _DisconnectFromDevice():
return disconnectFromDevice();case _RefreshData():
return refreshData();case _StartScan():
return startScan();case _StopScan():
return stopScan();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( BluetoothDeviceInfo device)?  connectToDevice,TResult? Function()?  disconnectFromDevice,TResult? Function()?  refreshData,TResult? Function()?  startScan,TResult? Function()?  stopScan,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _ConnectToDevice() when connectToDevice != null:
return connectToDevice(_that.device);case _DisconnectFromDevice() when disconnectFromDevice != null:
return disconnectFromDevice();case _RefreshData() when refreshData != null:
return refreshData();case _StartScan() when startScan != null:
return startScan();case _StopScan() when stopScan != null:
return stopScan();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements MainScreenEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent.started()';
}


}




/// @nodoc


class _ConnectToDevice implements MainScreenEvent {
  const _ConnectToDevice({required this.device});
  

 final  BluetoothDeviceInfo device;

/// Create a copy of MainScreenEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectToDeviceCopyWith<_ConnectToDevice> get copyWith => __$ConnectToDeviceCopyWithImpl<_ConnectToDevice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectToDevice&&(identical(other.device, device) || other.device == device));
}


@override
int get hashCode => Object.hash(runtimeType,device);

@override
String toString() {
  return 'MainScreenEvent.connectToDevice(device: $device)';
}


}

/// @nodoc
abstract mixin class _$ConnectToDeviceCopyWith<$Res> implements $MainScreenEventCopyWith<$Res> {
  factory _$ConnectToDeviceCopyWith(_ConnectToDevice value, $Res Function(_ConnectToDevice) _then) = __$ConnectToDeviceCopyWithImpl;
@useResult
$Res call({
 BluetoothDeviceInfo device
});




}
/// @nodoc
class __$ConnectToDeviceCopyWithImpl<$Res>
    implements _$ConnectToDeviceCopyWith<$Res> {
  __$ConnectToDeviceCopyWithImpl(this._self, this._then);

  final _ConnectToDevice _self;
  final $Res Function(_ConnectToDevice) _then;

/// Create a copy of MainScreenEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? device = null,}) {
  return _then(_ConnectToDevice(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as BluetoothDeviceInfo,
  ));
}


}

/// @nodoc


class _DisconnectFromDevice implements MainScreenEvent {
  const _DisconnectFromDevice();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisconnectFromDevice);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent.disconnectFromDevice()';
}


}




/// @nodoc


class _RefreshData implements MainScreenEvent {
  const _RefreshData();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent.refreshData()';
}


}




/// @nodoc


class _StartScan implements MainScreenEvent {
  const _StartScan();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartScan);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent.startScan()';
}


}




/// @nodoc


class _StopScan implements MainScreenEvent {
  const _StopScan();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StopScan);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainScreenEvent.stopScan()';
}


}




// dart format on
