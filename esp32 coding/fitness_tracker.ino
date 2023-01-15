/*
Arduino-MAX30100 oximetry / heart rate integrated sensor library
Copyright (C) 2016  OXullo Intersecans <x@brainrapers.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <Wire.h>
#include "MAX30100_PulseOximeter.h"
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <string>


#define REPORTING_PERIOD_MS     1000

// PulseOximeter is the higher level interface to the sensor
// it offers:
//  * beat detection reporting
//  * heart rate calculation
//  * SpO2 (oxidation level) calculation
PulseOximeter pox;

Adafruit_MPU6050 mpu;


#define SDA_2 32
#define SCL_2 33

#define SERVICE_UUID        "c7b43d86-bd78-44c6-baec-58e6d57e0177"
#define CHARACTERISTIC_ACCEL_UUID "d3016aa8-5785-45af-818c-5701e109bee6"
#define CHARACTERISTIC_GYRO_UUID "05ca63d1-e5e4-46f6-a019-5bbf2f4b1d43"
#define CHARACTERISTIC_HEARTRATE_UUID "c732333b-5716-4456-8cf5-4d1714a41e95"
#define CHARACTERISTIC_OXYGEN_SATURATION_UUID "1039a6a0-ea64-477e-9350-09cc5b3fa87e"

BLECharacteristic *pCharacteristicAccel = NULL;
BLECharacteristic *pCharacteristicGyro = NULL;
BLECharacteristic *pCharacteristicHeartRate = NULL;
BLECharacteristic *pCharacteristicOxygenSaturation = NULL;
BLEServer *pServer = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;



uint32_t tsLastReport = 0;


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

// Callback (registered below) fired when a pulse is detected
void onBeatDetected()
{
    Serial.println("Beat!");
}

void setup()
{
    Serial.begin(115200);
    BLEDevice::init("Fitness Tracker");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());
    BLEService *pService = pServer->createService(SERVICE_UUID);
    pCharacteristicAccel = pService->createCharacteristic(
      CHARACTERISTIC_ACCEL_UUID,
      BLECharacteristic::PROPERTY_READ   |
      BLECharacteristic::PROPERTY_WRITE  |
      BLECharacteristic::PROPERTY_NOTIFY |
      BLECharacteristic::PROPERTY_INDICATE
    );
    pCharacteristicGyro = pService->createCharacteristic(
      CHARACTERISTIC_GYRO_UUID,
      BLECharacteristic::PROPERTY_READ   |
      BLECharacteristic::PROPERTY_WRITE  |
      BLECharacteristic::PROPERTY_NOTIFY |
      BLECharacteristic::PROPERTY_INDICATE
    );
    pCharacteristicHeartRate = pService->createCharacteristic(
      CHARACTERISTIC_HEARTRATE_UUID,
      BLECharacteristic::PROPERTY_READ   |
      BLECharacteristic::PROPERTY_WRITE  |
      BLECharacteristic::PROPERTY_NOTIFY |
      BLECharacteristic::PROPERTY_INDICATE
    );
    pCharacteristicOxygenSaturation = pService->createCharacteristic(
      CHARACTERISTIC_OXYGEN_SATURATION_UUID,
      BLECharacteristic::PROPERTY_READ   |
      BLECharacteristic::PROPERTY_WRITE  |
      BLECharacteristic::PROPERTY_NOTIFY |
      BLECharacteristic::PROPERTY_INDICATE
    );

    // Create a BLE Descriptor
    pCharacteristicAccel->addDescriptor(new BLE2902());
    pCharacteristicGyro->addDescriptor(new BLE2902());
    pCharacteristicHeartRate->addDescriptor(new BLE2902());
    pCharacteristicOxygenSaturation->addDescriptor(new BLE2902());
    pService->start();

    // Set the device name and appearance
    // BLEDevice::setCustomGattService(pService);
    // BLEDevice::setAppearance(BLE_APPEARANCE_HEART_RATE_SENSOR_HEART_RATE_BELT);

    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(false);
    pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    Serial.println("Waiting for a client connection to notify...");
    Serial.print("Initializing pulse oximeter..");
    Wire.begin();
    Wire1.begin(SDA_2, SCL_2);

    // Initialize the PulseOximeter instance
    // Failures are generally due to an improper I2C wiring, missing power supply
    // or wrong target chip
    bool status = pox.begin(); 
    if (!status) {
        Serial.println("FAILED");
        for(;;);
    } else {
        Serial.println("SUCCESS");
    }
  // Try to initialize!
  bool status2 = mpu.begin(0x68,&Wire1); 
  if (!status2) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  Serial.print("Accelerometer range set to: ");
  switch (mpu.getAccelerometerRange()) {
  case MPU6050_RANGE_2_G:
    Serial.println("+-2G");
    break;
  case MPU6050_RANGE_4_G:
    Serial.println("+-4G");
    break;
  case MPU6050_RANGE_8_G:
    Serial.println("+-8G");
    break;
  case MPU6050_RANGE_16_G:
    Serial.println("+-16G");
    break;
  }
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  Serial.print("Gyro range set to: ");
  switch (mpu.getGyroRange()) {
  case MPU6050_RANGE_250_DEG:
    Serial.println("+- 250 deg/s");
    break;
  case MPU6050_RANGE_500_DEG:
    Serial.println("+- 500 deg/s");
    break;
  case MPU6050_RANGE_1000_DEG:
    Serial.println("+- 1000 deg/s");
    break;
  case MPU6050_RANGE_2000_DEG:
    Serial.println("+- 2000 deg/s");
    break;
  }

  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  Serial.print("Filter bandwidth set to: ");
  switch (mpu.getFilterBandwidth()) {
  case MPU6050_BAND_260_HZ:
    Serial.println("260 Hz");
    break;
  case MPU6050_BAND_184_HZ:
    Serial.println("184 Hz");
    break;
  case MPU6050_BAND_94_HZ:
    Serial.println("94 Hz");
    break;
  case MPU6050_BAND_44_HZ:
    Serial.println("44 Hz");
    break;
  case MPU6050_BAND_21_HZ:
    Serial.println("21 Hz");
    break;
  case MPU6050_BAND_10_HZ:
    Serial.println("10 Hz");
    break;
  case MPU6050_BAND_5_HZ:
    Serial.println("5 Hz");
    break;
  }

  Serial.println("");
  // delay(100);
    // The default current for the IR LED is 50mA and it could be changed
    //   by uncommenting the following line. Check MAX30100_Registers.h for all the
    //   available options.
    // pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);

    // Register a callback for the beat detection
    pox.setOnBeatDetectedCallback(onBeatDetected);
}

void loop()
{
    // Make sure to call update as fast as possible
    pox.update();

    // Asynchronously dump heart rate and oxidation levels to the serial
    // For both, a value of 0 means "invalid"
    if (millis() - tsLastReport > REPORTING_PERIOD_MS) {
        float heartRateData = pox.getHeartRate();
        float oxygenSaturationData = pox.getSpO2();
        /* Get new sensor events with the readings */
        sensors_event_t a, g, temp;
        mpu.getEvent(&a, &g, &temp);


        Serial.print("Heart rate:");
        Serial.print(heartRateData);
        Serial.print("bpm / SpO2:");
        Serial.print(oxygenSaturationData);
        Serial.println("%");

        /* Print out the values */
        Serial.print("Acceleration X: ");
        Serial.print(a.acceleration.x);
        Serial.print(", Y: ");
        Serial.print(a.acceleration.y);
        Serial.print(", Z: ");
        Serial.print(a.acceleration.z);
        Serial.println(" m/s^2");

        Serial.print("Rotation X: ");
        Serial.print(g.gyro.x);
        Serial.print(", Y: ");
        Serial.print(g.gyro.y);
        Serial.print(", Z: ");
        Serial.print(g.gyro.z);
        Serial.println(" rad/s");


        char heartrate[5];
        char oxygen[5];

        sprintf(heartrate, "%.2f",heartRateData);
        puts(heartrate);
        sprintf(oxygen, "%.2f",oxygenSaturationData);
        puts(oxygen);

        char accel[20];

        sprintf(accel, "%.2f %.2f %.2f", a.acceleration.x,a.acceleration.y, a.acceleration.z);
        puts(accel);

        char gyro[20];

        sprintf(gyro, "%.2f %.2f %.2f", g.gyro.x,g.gyro.y, g.gyro.z);
        puts(gyro);




        if(deviceConnected){
          pCharacteristicHeartRate->setValue(heartrate);
          pCharacteristicOxygenSaturation->setValue(oxygen);
          pCharacteristicAccel->setValue(accel);
          pCharacteristicGyro->setValue(gyro);
          pCharacteristicHeartRate->notify();
          pCharacteristicOxygenSaturation->notify();
          pCharacteristicAccel->notify();
          pCharacteristicGyro->notify();
          delay(3); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
        }


        // connecting
        if (deviceConnected && !oldDeviceConnected) {
            // do stuff here on connecting
            oldDeviceConnected = deviceConnected;
        }

        // disconnecting
        if (!deviceConnected && oldDeviceConnected) {
            delay(500); // give the bluetooth stack the chance to get things ready
            pServer->startAdvertising(); // restart advertising
            Serial.println("start advertising");
            oldDeviceConnected = deviceConnected;
        }

        Serial.println("");

        tsLastReport = millis();
    }

  // delay(500);
}
