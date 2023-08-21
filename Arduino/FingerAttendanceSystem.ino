#include <Wire.h>
#include <U8g2lib.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>
#include <Adafruit_Fingerprint.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include "WiFiManager.h" //https://github.com/tzapu/WiFiManager

#if (defined(__AVR__) || defined(ESP8266)) && !defined(__AVR_ATmega2560__)
SoftwareSerial mySerial(2, 3);
#else
#define mySerial Serial1
#endif
#define OLED_ADDRESS 0x3C 
#define RST_PIN 0        
#define SS_PIN 2         
#define BUZZER_PIN 15

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

// char ssid[] = "LINH HOMIE F3 A";        
// char password[] = "LINHHOMIEcamon"; 
int COUNT_TIME = 0;

void configModeCallback (WiFiManager *myWiFiManager)
{
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  Serial.println(myWiFiManager->getConfigPortalSSID());
}

void setup() {
  Serial.begin(115200);
  Wire.begin();
  finger.begin(57600);
  u8g2.begin();

  delay(5);
  if (finger.verifyPassword()) {
    Serial.println("Found fingerprint sensor!");
  } else {
    Serial.println("Did not find fingerprint sensor :(");
    while (1) { delay(1); }
  }
  WiFiManager wifiManager;
 
  wifiManager.setAPCallback(configModeCallback);
  if (!wifiManager.autoConnect())
  {
    Serial.println("failed to connect and hit timeout");
   
    ESP.reset();
    delay(1000);
  }
  
  Serial.println("connected...");

  // u8g2.clearBuffer();
  // u8g2.setFont(u8g2_font_ncenB08_tr);
  // u8g2.setCursor(0, 0);
  // u8g2.print("Connecting to WiFi...");
  // u8g2.sendBuffer();

  // while (WiFi.status() != WL_CONNECTED) {
  //   delay(1000);
  // }

  // u8g2.clearBuffer();
  // u8g2.print("Connected to WiFi!");
  // u8g2.sendBuffer();

  // delay(1000);

  displayMainScreen();

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  COUNT_TIME++;
  postMarkAbsent();
  checkAddStudent();
  getFinger();
  if (COUNT_TIME == 10){
    displayMainScreen();
    COUNT_TIME = 0;
  }

  delay(300);
}

void displayMainScreen() {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB14_tr);
  u8g2.setCursor(25, 16);
  u8g2.print("Student");
  u8g2.setCursor(10, 36);
  u8g2.print("Attendance");
  u8g2.sendBuffer();
  
}

void getFinger() {
  uint8_t p = finger.getImage();

  switch (p) {
    case FINGERPRINT_OK:
      Serial.println("Image taken");
      break;
    case FINGERPRINT_NOFINGER:
      Serial.println("No finger detected");
      return;
    case FINGERPRINT_PACKETRECIEVEERR:
      Serial.println("Communication error");
      return;
    case FINGERPRINT_IMAGEFAIL:
      Serial.println("Imaging error");
      return;
    default:
      Serial.println("Unknown error");
      return;
  }

    p = finger.image2Tz();
    switch (p) {
      case FINGERPRINT_OK:
        Serial.println("Image converted");
        break;
      case FINGERPRINT_IMAGEMESS:
        Serial.println("Image too messy");
        return;
      case FINGERPRINT_PACKETRECIEVEERR:
        Serial.println("Communication error");
        return;
      case FINGERPRINT_FEATUREFAIL:
        Serial.println("Could not find fingerprint features");
        return;
      case FINGERPRINT_INVALIDIMAGE:
        Serial.println("Could not find fingerprint features");
        return;
      default:
        Serial.println("Unknown error");
        return;
    }


    // OK converted!
    p = finger.fingerSearch();
    if (p == FINGERPRINT_OK) {
      Serial.println("Found a print match!");  
      Serial.print("Found ID #"); Serial.print(finger.fingerID);
      Serial.print(" with confidence of "); Serial.println(finger.confidence);
      std::string tagID = std::to_string(finger.fingerID);
      COUNT_TIME = 0;
      postTakeAttendance(tagID.c_str());
    } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
      Serial.println("Communication error");
      return;
    } else if (p == FINGERPRINT_NOTFOUND) {
      Serial.println("Did not find a match");
      return;
    } else {
      Serial.println("Unknown error");
      return;
    }
  
}

void checkAddStudent(){
  String url = "http://www.nqngoc.id.vn/get_CheckHasAddStudent.php";
  WiFiClient client;
  HTTPClient http;
  String payload = "";
  http.begin(client, url);

  int httpResponseCode = http.GET();
  if (httpResponseCode == HTTP_CODE_OK) {
    payload = http.getString();
  }
  http.end();
  StaticJsonDocument<192> doc;

  DeserializationError error = deserializeJson(doc, payload);
  
   if (doc.containsKey("error")){
    return;
   } else {
      const char* rfid = doc["rfid"];
      int id =  atoi(rfid);
      enrollNewFinger(id);
   }
}

void enrollNewFinger(int id) {
  while (true){
    int p = -1;
    u8g2.clearBuffer();
    u8g2.setFont(u8g2_font_ncenB08_tr);
    u8g2.setCursor(5, 10);
    u8g2.print("Put Your Finger In");
    u8g2.sendBuffer();
    while (p != FINGERPRINT_OK) {
      p = finger.getImage();
      switch (p) {
      case FINGERPRINT_OK:
        Serial.println("Image taken");
        break;
      case FINGERPRINT_NOFINGER:
        Serial.println(".");
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        Serial.println("Communication error");
        break;
      case FINGERPRINT_IMAGEFAIL:
        Serial.println("Imaging error");
        break;
      default:
        Serial.println("Unknown error");
        break;
        }
    }
    bool check = false;
    p = finger.image2Tz(1);
    switch (p) {
      case FINGERPRINT_OK:
        Serial.println("Image converted");
        digitalWrite(BUZZER_PIN, HIGH);
        delay(150);
        digitalWrite(BUZZER_PIN, LOW);
        u8g2.clearBuffer();
        check = true;
        break;
      case FINGERPRINT_IMAGEMESS:
        Serial.println("Image too messy");
        check = false;
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        Serial.println("Communication error");
        check = false;
        break;
      case FINGERPRINT_FEATUREFAIL:
        Serial.println("Could not find fingerprint features");
        check = false;
        break;
      case FINGERPRINT_INVALIDIMAGE:
        Serial.println("Could not find fingerprint features");
        check = false;
        break;
      default:
        Serial.println("Unknown error");
        check = false;
        break;
    } 
    if (check){
      delay(2000);
      p = 0;
      while (p != FINGERPRINT_NOFINGER) {
         p = finger.getImage();
      }
      u8g2.setFont(u8g2_font_ncenB08_tr);
      u8g2.setCursor(5, 10);
      u8g2.print("Put Your Finger Again");
      u8g2.sendBuffer();
      postNewStatusAddStudent("Again");
      p = -1;
      while (p != FINGERPRINT_OK) {
        p = finger.getImage();
        switch (p) {
        case FINGERPRINT_OK:
          Serial.println("Image taken");
          break;
        case FINGERPRINT_NOFINGER:
          Serial.print(".");
          break;
        case FINGERPRINT_PACKETRECIEVEERR:
          Serial.println("Communication error");
          break;
        case FINGERPRINT_IMAGEFAIL:
          Serial.println("Imaging error");
          break;
        default:
          Serial.println("Unknown error");
          break;
        }
      }
      check = false;
      p = finger.image2Tz(2);
      switch (p) {
        case FINGERPRINT_OK:
          Serial.println("Image converted");
          check = true;
          break;
        case FINGERPRINT_IMAGEMESS:
          Serial.println("Image too messy");
          check = false;
          break;
        case FINGERPRINT_PACKETRECIEVEERR:
          Serial.println("Communication error");
          check = false;
          break;
        case FINGERPRINT_FEATUREFAIL:
          Serial.println("Could not find fingerprint features");
          check = false;
          break;
        case FINGERPRINT_INVALIDIMAGE:
          Serial.println("Could not find fingerprint features");
          check = false;
          break;
        default:
          Serial.println("Unknown error");
          check = false;
          break;
      } 
      if (check) {
        p = finger.createModel();
        check = false;
        if (p == FINGERPRINT_OK) {
          Serial.println("Prints matched!");
          check = true;
        } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
          Serial.println("Communication error");
          check = false;
        } else if (p == FINGERPRINT_ENROLLMISMATCH) {
          Serial.println("Fingerprints did not match");
          check = false;
        } else {
          Serial.println("Unknown error");
          check = false;
        }
        if (check){
          p = finger.storeModel(id);
          check = false;
          if (p == FINGERPRINT_OK) {
            Serial.println("Stored!");
            check = true;
          } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
            Serial.println("Communication error");
            check = false;
          } else if (p == FINGERPRINT_BADLOCATION) {
            Serial.println("Could not store in that location");
            check = false;
          } else if (p == FINGERPRINT_FLASHERR) {
            Serial.println("Error writing to flash");
            check = false;
          } else {
            Serial.println("Unknown error");
            check = false;
          }
          if (check) {
              digitalWrite(BUZZER_PIN, HIGH);
              delay(150);
              digitalWrite(BUZZER_PIN, LOW);
              u8g2.clearBuffer();
              u8g2.setFont(u8g2_font_ncenB08_tr);
              u8g2.setCursor(5, 10);
              u8g2.print("Add Finger Success");
              u8g2.sendBuffer();
              postNewStatusAddStudent("Success");
              delay(2000);
              postAddNewStudentSuccess();
              displayMainScreen();
              return;

          } else postNewStatusAddStudent("Waiting");
        } else postNewStatusAddStudent("Waiting");
      } else postNewStatusAddStudent("Waiting");  
    } else postNewStatusAddStudent("Waiting");  
    delay(1000);
  }
}

void postAddNewStudentSuccess() {
  String url = "http://www.nqngoc.id.vn/post_AddNewStudent_Success.php";
  WiFiClient client;
  HTTPClient http;
  http.begin(client, url);

  int httpResponseCode = http.GET();

  http.end();
}

void postNewStatusAddStudent(String status){
  String url = "http://www.nqngoc.id.vn/post_NewStatusAddStudent.php";
  WiFiClient client;
  HTTPClient http;
  http.begin(client, url);

  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  String postData = "status=" + status;
  int httpResponseCode = http.POST(postData);

  http.end();
}

void postMarkAbsent() {
  String url = "http://www.nqngoc.id.vn/post_MarkAbsent.php";
  WiFiClient client;
  HTTPClient http;
  http.begin(client, url);

  int httpResponseCode = http.POST("a");

  http.end();
}

void postTakeAttendance(String tagID) {
  String url = "http://www.nqngoc.id.vn/post_TakeAttendance.php";
  WiFiClient client;
  HTTPClient http;
  String payload = "";

  http.begin(client, url);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  String postData = "rfid=" + tagID;
  int httpResponseCode = http.POST(postData);

  if (httpResponseCode == HTTP_CODE_OK) {
    payload = http.getString();
    http.end();
  }

  http.end();

  parseStudentInfo(tagID, payload);
}

void parseStudentInfo(String tagID, String studentInfo) {
  StaticJsonDocument<192> doc;

  DeserializationError error = deserializeJson(doc, studentInfo);

  if (doc.containsKey("error")) {
    const char* errorMsg = doc["error"];
    if (strcmp(errorMsg,"Student Not Found") == 0){
      
    } else 
    if (strcmp(errorMsg,"No Schedule") == 0){
      digitalWrite(BUZZER_PIN, HIGH);
      delay(150);
      digitalWrite(BUZZER_PIN, LOW);
      displayStudentInformation("No Schedule","");
    } else 
    if (strcmp(errorMsg,"New Student") == 0){
      displayStudentInformation("No Schedule","");
    }
    return;
  }
  const char* name = doc["Name"];
  const char* studentCode = doc["Student_Code"]; 
  digitalWrite(BUZZER_PIN, HIGH);
  delay(150);
  digitalWrite(BUZZER_PIN, LOW);
  displayStudentInformation(name, studentCode);

}

void displayStudentInformation(String name, String studentCode) {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB08_tr);

  u8g2.setCursor(5, 10);
  u8g2.print(name);
  u8g2.setCursor(5, 25);
  u8g2.print(studentCode);

  u8g2.sendBuffer();
}
