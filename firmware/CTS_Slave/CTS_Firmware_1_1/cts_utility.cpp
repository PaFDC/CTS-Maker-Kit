#include <Arduino.h>
#include "cts_utility.h"

void initCTS()
{
  TCCR1A = 0; // Clear initial settings (use 16 bit timing)
  TCCR1B = (1 << WGM12) | (1 << CS10); // Clear timer on Compare and set prescaler to 1

  // Output Compare Register reset ticks
  OCR1A = 8191; // 8191 clock ticks, about 1 ms
  OCR1B = 5000;

  TCNT1 = 0; // Reset timer counter 1

  TIMSK1 |= (1 << OCIE1A) | (1 << OCIE1B); // (1 << TOIE1) | Enable TIMER1 overflow interrupt and output compare interrupt

  DDRD &= ~((1 << DDD2) | (1 << DDD3)); // Set input on pins 7 and 8 (Signal in)
  // I2C uses PD0 and PD1
  DDRB |= (1 << DDB6) | (1 << DDB5);    // Set output on pins 14 and 15 (Signal out)
  DDRD |= (1 << DDD5) | (1 << DDD6); // Set output on pins 1 and 2 (ISR out, debugging)
  DDRF |= (1 << DDF0); // Set output on pin 21 (Trigger out, debugging)

  EICRA |= (1 << ISC30) | (1 << ISC20); // Fire interrupts on a change in external input
  //EICRA |= (1 << ISC10) | (1 << ISC00) | (1 << ISC11) | (1 << ISC01); // Fire interrupts on a rising edge external input
  EIMSK |= (1 << INT3) | (1 << INT2); // Enable external interrupts

  sei(); // Set enable interrupts
}



