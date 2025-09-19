#!/usr/bin/env python
import RPi.GPIO as GPIO
import argparse

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

USB2_OPZ = 13
USB3_OWRT = 19
DC12V1 = 26
DC12V2 = 16
AC1_M3P = 21
AC2_NAS = 20

LOOKUP = {
    'opz': USB2_OPZ, 
    'owrt': USB3_OWRT, 
    '12v1': DC12V1, 
    '12v2': DC12V2, 
    'm3p': AC1_M3P, 
    'nas': AC2_NAS
}

GPIO.setup(USB2_OPZ, GPIO.OUT)
GPIO.setup(USB3_OWRT, GPIO.OUT)
GPIO.setup(DC12V1, GPIO.OUT)
GPIO.setup(DC12V2, GPIO.OUT)
GPIO.setup(AC1_M3P, GPIO.OUT)
GPIO.setup(AC2_NAS, GPIO.OUT)

GPIO.output(USB2_OPZ, GPIO.LOW)
GPIO.output(USB3_OWRT, GPIO.LOW)
GPIO.output(DC12V1, GPIO.LOW)
GPIO.output(DC12V1, GPIO.LOW)
GPIO.output(AC1_M3P, GPIO.LOW)
GPIO.output(AC1_M3P, GPIO.LOW)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', choices=['opz', 'owrt', '12v1', '12v2', 'm3p', 'nas', 'all'], default='all', help='opz - Orange Pi Zero, owrt - OpenWRT, 12v1 - 12V Output 1, 12v2 - 12V Output 2, m3p - Gmktec M3 Puls, nas - Radxa X4')
    parser.add_argument('-s', '--state', choices=['off', 'on'], default='off', help='off, on')
    args = parser.parse_args()
    
    if args.state == 'on':
        state = GPIO.HIGH
    else:
        state = GPIO.LOW
    
    if args.out == 'all':
        print(f"Setting all outputs to {args.state}")
        GPIO.output(USB2_OPZ, state)
        GPIO.output(USB3_OWRT, state)
        GPIO.output(DC12V1, state)
        GPIO.output(DC12V1, state)
        GPIO.output(AC1_M3P, state)
        GPIO.output(AC1_M3P, state)
    else:
        print(f"Setting output {args.out} to {args.state}")
        GPIO.output(LOOKUP[args.out], state)