#include <TimerOne.h>
#include "proj_types.h"

int pwm1 = 0;
int pwm2 = 0;

const int PWM_Pin1 = 6;
const int PWM_Pin2 = 5; 

const int out_dir = 7;
const int out_dir2 = 4;

const int enc_fase1a = 2;
const int enc_fase2a = 3;

const int enc_fase1b = 9;
const int enc_fase2b = 10;

const int Bat_ON_Pin = 8;
const int LedPin = 13;
const int ButtonLedPin = 11;

#define RELAY_ON 0
#define RELAY_OFF 1 

const int VBatPin = A0;
const int IBatPin = A1;

// 2  <- enc1a
// 3  <- enc2a
// 4  -> Dir1
// 5  -> PWM1
// 6  -> PWM2
// 7  -> Dir2
// 8  -> Bat_on
// 9  <- enc1b
// 10 <- enc2b
// 11 -> Button LED
// 12
// 13 -> Debug LED

// A0 <- VBat
// A1 <- IBat
// A2
// A3
// A4
// A5
// A6

byte enc1_state, old1_state;

volatile unsigned int enc1;

byte enc2_state, old2_state;

volatile unsigned int enc2;

unsigned long currentTime;
unsigned long loopTime;

PID_t pid[2];
int odo[2];
int last_odo[2];

float w_odo[2];
float w_ref[2];
int PID_out[2];

int frame;
char curChannel;
char frameHexData[4];

void setup_time()
{
  currentTime = millis();
  loopTime = currentTime;  
}

void setup_PIDs(void)
{
  pid[0].Kp = 0.008;
  pid[0].Ki = 1e-2;
  pid[0].Kd = 0; //1e-3;
  pid[0].Kf = 1.5e-3;
  pid[0].scale = 255;
  pid[0].dt = 0.04;
  pid[0].active = 1;

  pid[1] = pid[0];
}

float calc_pid(PID_t& pid, float w_ref, float w)
{
  float de, Se;
  pid.e = w_ref - w;
  pid.last_e = pid.e;
  pid.w = w;
  pid.w_ref = w_ref;

  Se = pid.Se + pid.e * pid.dt;
  de = (pid.e - pid.last_e) / pid.dt;
  
  // Remove integration for zero reference
  if (w_ref == 0) {
    Se = 0;
  }

  // Calc PID output
  pid.m = pid.Kp * pid.e + pid.Ki * Se + pid.Kd * de + pid.Kf * pid.w_ref;

  // Anti windup
  if (abs(pid.m) > 1) {
    pid.m = pid.m + pid.Ki * (pid.Se - Se);
  } else {
    pid.Se = Se;
  }

  if (pid.m > 1) {
    pid.m = 1;
  } else if (pid.m < -1) {
    pid.m = -1;
  }

  return pid.m * pid.scale;
}


void setup()
{
  enc1_state = 0;
  enc1 = 0;
  enc2_state = 0;
  enc2 = 0;

  setup_PIDs();
  
  digitalWrite(LedPin, 0);
  pinMode(LedPin, OUTPUT);

  digitalWrite(ButtonLedPin, 0);
  pinMode(ButtonLedPin, OUTPUT);
  
  digitalWrite(Bat_ON_Pin, RELAY_OFF);
  pinMode(Bat_ON_Pin, OUTPUT);
  
  pinMode(enc_fase1a, INPUT);
  digitalWrite(enc_fase1a, HIGH);

  pinMode(enc_fase2a, INPUT);
  digitalWrite(enc_fase2a, HIGH);
  
  pinMode(enc_fase1b, INPUT);
  digitalWrite(enc_fase1b, HIGH);

  pinMode(enc_fase2b, INPUT);
  digitalWrite(enc_fase2b, HIGH);

  pinMode(out_dir, OUTPUT);
  pinMode(out_dir2, OUTPUT);

  pinMode(VBatPin, INPUT);
  pinMode(IBatPin, INPUT);

  old1_state = (digitalRead(enc_fase2a) << 1) + digitalRead(enc_fase1a);
  old2_state = (digitalRead(enc_fase2b) << 1) + digitalRead(enc_fase1b);
  
  
  digitalWrite(out_dir, LOW);
  digitalWrite(out_dir2, LOW);
  analogReference(DEFAULT);
  
  Timer1.initialize(100);            // initialize timer1, and set a 10k frequency  
  Timer1.attachInterrupt(callback);  // attaches callback() as a timer overflow interrupt

  motor1(0);
  motor2(0);
  
  frame = -1;
  Serial.begin(115200);
  Serial.println("Serial channels");
  sendChannel('G', 0);
  Serial.println();

  w_ref[0] = 0;
  w_ref[1] = 0;

  // Faster PWM for timer0 prescaler from 64 to 8;
  //TCCR0B &= ~(1 << CS00);
  
}

void callback(void)
{
  
  if (digitalRead(enc_fase2a)) enc1_state = 2;
  else enc1_state = 0;
  if (digitalRead(enc_fase1a)) enc1_state += 1;
  
   if (digitalRead(enc_fase2b)) enc2_state = 2;
  else enc2_state = 0;
  if (digitalRead(enc_fase1b)) enc2_state += 1;
  
/////////////////////
  if (old1_state == 0) { 
    if (enc1_state == 1) {
      enc1++;
    }

    if (enc1_state == 2) {
      enc1--;
    }
  }

  if (old1_state == 1) { 
    if (enc1_state == 3) {
      enc1++;
    }

    if (enc1_state == 0) {
      enc1--;
    }
  }


  if (old1_state == 2) { 
    if (enc1_state == 0) {
      enc1++;
    }

    if (enc1_state == 3) {
      enc1--;
    }
  }

  if (old1_state == 3) { 
    if (enc1_state == 2)  {
      enc1++;
    }

    if (enc1_state == 1) {
      enc1--;
    }
  }
 
  old1_state = enc1_state;

//////////////
  if (old2_state == 0) { 
    if (enc2_state == 1) {
      enc2++;
    }

    if (enc2_state == 2) {
      enc2--;
    }
  }

  if (old2_state == 1) { 
    if (enc2_state == 3) {
      enc2++;
    }

    if (enc2_state == 0) {
      enc2--;
    }
  }

  if (old2_state == 2) { 
    if (enc2_state == 0) {
      enc2++;
    }

    if (enc2_state == 3) {
      enc2--;
    }
  }

  if (old2_state == 3) { 
    if (enc2_state == 2) {
      enc2++;
    }

    if (enc2_state == 1) {
      enc2--;
    }
  }
 
  old2_state = enc2_state;

}

////////////
void sendHexNibble(byte b)
{
  if (b < 10) {
    Serial.write('0' + b);
  } else if (b < 16) {
    Serial.write('A' + (b - 10));
  }
}

void sendHexByte(byte b)
{
  sendHexNibble(b >> 4); 
  sendHexNibble(b & 0x0F); 
}


void sendChannel(unsigned char c, int v)
{
  Serial.write(c); 
  sendHexByte(v >> 8);
  sendHexByte(v & 0xFF);
}

byte isHexNibble(char c)
{
  if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F')) return 1;
  else return 0;
}

void motor1(int pwm)
{
  if (pwm > 0) {
    digitalWrite(out_dir, LOW);
    analogWrite(PWM_Pin1, pwm);
  } else {
    digitalWrite(out_dir, HIGH);
    analogWrite(PWM_Pin1, -pwm);
  }
}

void motor2(int pwm)
{
  if (pwm < 0) {
    digitalWrite(out_dir2, LOW);
    analogWrite(PWM_Pin2, -pwm);
  } else {
    digitalWrite(out_dir2, HIGH);
    analogWrite(PWM_Pin2, pwm);
  }
}

byte HexNibbleToByte(char c)
{
  if (c >= '0' && c <= '9') return c - '0';
  else if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  else return 0;
}

void processFrame(void)
{
  int value;
  value = (HexNibbleToByte(frameHexData[0]) << 12) +
          (HexNibbleToByte(frameHexData[1]) << 8)  +
          (HexNibbleToByte(frameHexData[2]) << 4)  +
           HexNibbleToByte(frameHexData[3]);

  if (curChannel == 'M') {
    pwm1 = value - 255;     
    motor1(pwm1);
  } else if (curChannel == 'N') {
    pwm2 = value - 255;     
    motor2(pwm2);
  } else if (curChannel == 'R') {
    w_ref[0] = value;
  } else if (curChannel == 'S') {
    w_ref[1] = value;
  } else if (curChannel == 'P') {
    pid[0].active = value;
    pid[1].active = value;
  }
  
}

int AD_bat;

void loop()
{
  byte b, i;
  
  unsigned long stop;

  AD_bat = (15 * AD_bat + analogRead(VBatPin)) / 16; 
  if (AD_bat > 600) {
    digitalWrite(ButtonLedPin, 1);    
  } else {
    digitalWrite(ButtonLedPin, 0); 
  }
  
  currentTime = millis();// / 8;

  if(currentTime >= 1000){  
    digitalWrite(Bat_ON_Pin, RELAY_ON);    
    digitalWrite(LedPin, 1);    
  }
  
  if(currentTime >= (loopTime + 40)) {


    for(i = 0; i < 2; i++) {
      last_odo[i] = odo[i];
    }
    odo[0] = enc1;
    odo[1] = enc2;

    for(i = 0; i < 2; i++) {
      w_odo[i] = odo[i] - last_odo[i];
      PID_out[i] = calc_pid(pid[i], w_ref[i], w_odo[i]);
    }


    if(pid[0].active) motor1(PID_out[0]);
    if(pid[1].active) motor2(PID_out[1]);
   
    sendChannel('V', enc1);
    sendChannel('W', enc2);

    sendChannel('U', AD_bat * (1646.0 / 698.0));
    sendChannel('I', analogRead(IBatPin));

    sendChannel('v', w_odo[0]);
    sendChannel('w', w_odo[1]);

    //stop =  millis();
    //sendChannel('L', stop - currentTime);
    Serial.println();

    loopTime = loopTime + 40;  // Updates loopTime
  }

  // Serial State machine
  if (Serial.available() > 0) {
    b = Serial.read();
    
    switch (frame) {
      case -1: 
        if (b >= 'I' && b <= 'Z') {
          frame = 0;
          curChannel = b;
        }
        break;
      case 0:
        if (isHexNibble(b)) {
          frameHexData[frame] = b;
          frame = 1;
        }
        break;
      case 1:
        if (isHexNibble(b)) {
          frameHexData[frame] = b;
          frame = 2;
        }
        break;
      case 2:
        if (isHexNibble(b)) {
          frameHexData[frame] = b;
          frame = 3;
        }
        break;
      case 3:
        if (isHexNibble(b)) {
          frameHexData[frame] = b;
          processFrame();
          frame = -1;
        }
        break;        
      }
     
  }
}


// 0x2BA -> 698 - > 16.46 V


