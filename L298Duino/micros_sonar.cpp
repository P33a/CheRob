/* Copyright (c) 2017  Paulo Costa
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the copyright holders nor the names of
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

#include "micros_sonar.h"
#include "Arduino.h"

micros_sonar_t SonarA(2);
micros_sonar_t SonarB(3);

enum sonar_states_t {ss_init, ss_idle, ss_trigering, ss_wait_for_start_measuring, ss_wait_for_stop_measuring, ss_error};

unsigned long us;
 
void ISR_pin_2(void)
{
  us = micros();
  if (SonarA.state == ss_wait_for_start_measuring) {
    if (digitalRead(2)) {
      SonarA.measure_start = us;
      SonarA.state = ss_wait_for_stop_measuring;
    } else {
      SonarA.state = ss_error; 
    }
  } else if (SonarA.state == ss_wait_for_stop_measuring) {
    if (digitalRead(2) == 0) {
      SonarA.measure = us - SonarA.measure_start;
      SonarA.state = ss_idle;
    } else {
      SonarA.state = ss_error; 
    }
  }
}

void ISR_pin_3(void)
{
  us = micros();
  if (SonarB.state == ss_wait_for_start_measuring) {
    if (digitalRead(3)) {
      SonarB.measure_start = us;
      SonarB.state = ss_wait_for_stop_measuring;
    } else {
      SonarB.state = ss_error; 
    }
  } else if (SonarB.state == ss_wait_for_stop_measuring) {
    if (digitalRead(3) == 0) {
      SonarB.measure = us - SonarB.measure_start;
      SonarB.state = ss_idle;
    } else {
      SonarB.state = ss_error; 
    }
  }
}


void micros_sonar_t::init(int8_t new_trigger_pin)
{
  trigger_pin = new_trigger_pin;

  digitalWrite(trigger_pin, 0);
  pinMode(trigger_pin, OUTPUT);
  
  pinMode(echo_pin, INPUT_PULLUP);
  if (echo_pin == 2)  attachInterrupt(digitalPinToInterrupt(echo_pin), ISR_pin_2, CHANGE);
  if (echo_pin == 3)  attachInterrupt(digitalPinToInterrupt(echo_pin), ISR_pin_3, CHANGE);
  state = ss_idle;
}

void micros_sonar_t::start_measure(int timeout_ms)
{
  state = ss_trigering;
  digitalWrite(trigger_pin, 1);
  trig_start = micros();
  timeout = 1000UL * timeout_ms;
  delayMicroseconds(10);  
  state = ss_wait_for_start_measuring;
  digitalWrite(trigger_pin, 0);
}


uint8_t micros_sonar_t::measure_available(void)
{
  if (micros() - trig_start > timeout) state = ss_error;
  return state == ss_idle || state == ss_error;
}

unsigned long micros_sonar_t::read_measure(void)
{
  if (state == ss_idle) return measure;
  else return 0;
}

micros_sonar_t::micros_sonar_t(int8_t new_echo_pin)
{
  state = ss_init;
  echo_pin = new_echo_pin;
}





