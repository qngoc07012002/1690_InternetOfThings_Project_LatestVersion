#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <SPI.h>
#include <MFRC522.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

#define OLED_ADDRESS 0x3C 
#define RST_PIN 0         
#define SS_PIN 2          
#define BUZZER_PIN 15

Adafruit_SSD1306 display(128, 64, &Wire, -1);
MFRC522 mfrc522(SS_PIN, RST_PIN);

char ssid[] = "LINH HOMIE F3 A";       
char password[] = "LINHHOMIEcamon";

void setup() {
  Serial.begin(115200);
  Wire.begin();
  SPI.begin();
  mfrc522.PCD_Init();
  WiFi.begin(ssid, password);

  display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDRESS);

  display.clearDisplay();
  display.setTextColor(WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    display.println("Connecting to WiFi...");
    
  }
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0,0);
  display.println("Connected to WiFi!");
  display.display();

  delay(1000);

  display.clearDisplay();
  display.setTextSize(2);
  display.setCursor(20, 0);
  display.println("Student");
  display.println("Attendance");
  display.display();

  pinMode(BUZZER_PIN, OUTPUT); 
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {

  if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) {
    delay(100);
    return;
  }

  String tagID = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    tagID.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : ""));
    tagID.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  tagID.toUpperCase();
  mfrc522.PICC_HaltA();

  // display.clearDisplay();
  // display.setTextColor(WHITE);
  // display.setTextSize(2);
  // display.setCursor(0, 0);
  // display.println("RFID:");
  // display.setTextSize(2);
  // display.setCursor(0, 24);
  // display.println(tagID);
  // display.display();

  // postNewStudent(tagID);
  
  getStudentInfo(tagID);
  



  digitalWrite(BUZZER_PIN, HIGH);
  delay(300);
  digitalWrite(BUZZER_PIN, LOW);

  delay(1000);
}

void postNewStudent(String tagID) {
  String url = "http://www.nqngoc.id.vn/post_NewStudent.php";
  WiFiClient client; 
  HTTPClient http;
  http.begin(client, url); 

  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  String postData = "rfid=" + tagID;
  int httpResponseCode = http.POST(postData);

  http.end();
}

void getStudentInfo(String tagID) {
  String url = "http://www.nqngoc.id.vn/get_StudentInfomation.php?rfid=" + tagID;
  WiFiClient client; 
  HTTPClient http;
  String payload = "";

  http.begin(client, url);
  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {
    payload = http.getString();
    http.end();
    
  }

  http.end();

  parseStudentInfo(tagID, payload);
}

void parseStudentInfo(String tagID, String studentInfo) {
  StaticJsonDocument<192> doc;

  DeserializationError error = deserializeJson(doc, studentInfo);

  if (error) {
  Serial.print(F("deserializeJson() failed: "));
  Serial.println(error.f_str());
  return;
  }
  const char* name = doc["Name"];
  const char* studentCode = doc["Student_Code"]; 

  displayStudentInformation(tagID, name, studentCode);

}

void displayStudentInformation(String rfid, String name, String studentCode) {
  if (name.isEmpty()) {
    Serial.println(rfid);
    postNewStudent(rfid);
    display.clearDisplay();
    display.setTextSize(1);
    display.setCursor(0, 5);
    display.println("New Student");
    display.display();
  } else {
    display.clearDisplay();
    display.setTextSize(1);
    display.setCursor(0, 5);
    display.println(name);
    display.setCursor(0, 40);
    display.println(studentCode);
    display.display();
  }
}
