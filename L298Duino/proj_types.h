#ifndef PROJ_TYPES_H
#define PROJ_TYPES_H

#include "Arduino.h"

// Servo types
typedef struct{
    float dt, Ki, Kp, Kd, Kf;
    float w, w_ref;
    float e, last_e, Se;
    float m, scale;
    byte active;
} PID_t;


typedef union {
  struct {
    unsigned char b0  : 1;
    unsigned char b1  : 1;
    unsigned char b2  : 1;
    unsigned char b3  : 1;
    unsigned char b4  : 1;
    unsigned char b5  : 1;
    unsigned char b6  : 1;
    unsigned char b7  : 1;
  } bits;
  
  byte b;
  
} bits8_t;


typedef struct {
   byte l, h;
} word_bytes;

typedef union {
  struct {
    unsigned char b0  : 1;
    unsigned char b1  : 1;
    unsigned char b2  : 1;
    unsigned char b3  : 1;
    unsigned char b4  : 1;
    unsigned char b5  : 1;
    unsigned char b6  : 1;
    unsigned char b7  : 1;
    unsigned char b8  : 1;
    unsigned char b9  : 1;
    unsigned char b10 : 1;
    unsigned char b11 : 1;
    unsigned char b12 : 1;
    unsigned char b13 : 1;
    unsigned char b14 : 1;
    unsigned char b15 : 1;
  } bits;
  
  word_bytes b;

  uint16_t word;
  
} bits16_t;


#endif // PROJ_TYPES_H 
