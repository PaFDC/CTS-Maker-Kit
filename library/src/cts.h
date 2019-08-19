#include <Arduino.h>
#include <Wire.h>

#ifndef CTS_H
  #define CTS_H

  #define CTS_CONTINUOUS_MODE   (1)   //
  #define CTS_EVENT_MODE        (2)   //

  #define CTS_DATA_LENGTH_ERROR (1)   //

  #define CTS_BUFFER_LENGTH     (24)  //
  #define I2C_SEND_STOP         (1)   //

  struct CTSDataStruct{
    float raw[2];
    float highpass[2];
    float x;
    float pressure;
  };

  class CTS {
    public:
      CTS(TwoWire *);
      CTS(TwoWire *, uint8_t);
      void address(uint8_t);
      uint8_t address();
      void onPress(void (* function)(CTSDataStruct));
      void onHold(void (* function)(CTSDataStruct));
      void onRelease(void (* function)(CTSDataStruct));
      void onError(void (* function)(int));
      void update(void);

      void onPressThreshold(float threshold);
      float onPressThreshold(void);
      void onReleaseThreshold(float threshold);
      float onReleaseThreshold(void);

    private:

      void (* _pressCallback)(CTSDataStruct);
      void (* _holdCallback)(CTSDataStruct);
      void (* _releaseCallback)(CTSDataStruct);
      void (* _errorCallback)(int);

      int _readBuffer(uint8_t* buffer, int bytes);

      TwoWire *_wire;

      uint8_t _address;
      float _press_threshold = 1.0;
      float _release_threshold = -1.0;
      uint8_t _istouched = false;
      struct CTSDataStruct _dataStruct;
  };

#endif
