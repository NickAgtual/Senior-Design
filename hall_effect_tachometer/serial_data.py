import serial
import time

def read_serial_data(comm_port, baud_rate, time_stamp = False):
    
    serial_port = serial.Serial(comm_port, baud_rate, timeout=0.1)

    while True:
        data = serial_port.readline().decode().strip()
        if data and time_stamp:
            time_stamp = time.strftime('%H:%M:%S')
            print(f'{time_stamp} > data')
        elif data:
            print(data)


if __name__ == '__main__':
    read_serial_data('COMM5', 9600, True)
