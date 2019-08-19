#include <Arduino.h>
#include <Wire.h>
#include "cts.h"

CTS::CTS(TwoWire *wire) {
  _wire = wire;
  _wire->begin();
}

CTS::CTS(TwoWire *wire, uint8_t address) {
  _address = address;
  _wire = wire;
  _wire->begin();
}

void CTS::address(uint8_t address) {
  _address = address;
}

uint8_t CTS::address() {
  return _address;
}

void CTS::update() {
  int res = CTS::_readBuffer((uint8_t *) _dataStruct, 24);

  if (!res) {
    if (_dataStruct.highpass[0] + _dataStruct.highpass[1] > _press_threshold && !_istouched) {
      _istouched = true;
      CTS::_pressCallback(_dataStruct);
    } else if (_istouched) {
      CTS::_holdCallback(_dataStruct);
    } else if (_dataStructUnion.ds.highpass[0] + _dataStructUnion.ds.highpass[1] < _release_threshold && _istouched) {
      _istouched = false;
      CTS::_releaseCallback(_dataStructUnion.ds);
    }
  } else {
    CTS::_errorCallback(res);
  }
}

void CTS::onPressThreshold(float threshold) {
  _press_threshold = threshold;
}

void CTS::onReleaseThreshold(float threshold) {
  _release_threshold = threshold;
}

float CTS::onPressThreshold() {
  return _press_threshold;
}

float CTS::onReleaseThreshold() {
  return _release_threshold;
}


void CTS::onPress(void (* function)(CTSDataStruct)) {
  CTS::_pressCallback = function;
}

void CTS::onHold(void (* function)(CTSDataStruct)) {
  CTS::_holdCallback = function;
}

void CTS::onRelease(void (* function)(CTSDataStruct)) {
  CTS::_releaseCallback = function;
}

void CTS::onError(void (* function)(int)) {
  CTS::_errorCallback = function;
}


int CTS::_readBuffer(uint8_t* buffer, int bytes) {
  _wire->requestFrom(_address, CTS_BUFFER_LENGTH, I2C_SEND_STOP);
  for (int i = 0; i < bytes; i++) {
    if (_wire->available()) {
      buffer[i] = _wire->read();
    } else {
      return CTS_DATA_LENGTH_ERROR; // If there is no more data but more is requested, exit with error code 1
    }
  }
  return 0; // Exit without error
}
