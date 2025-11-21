#include "receiver.h"
#include <cstring>
#include <cstdint>
#include <sys/types.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <QDebug>
#include <cerrno>

Receiver::Receiver(QObject *parent):
    QThread(parent), socketCAN(-1), ifr(), addr(){}

Receiver::~Receiver() {
    if (this->socketCAN >= 0) {
        close(this->socketCAN);
    }
}

Receiver::Receiver(const Receiver& rcv):
    QThread(rcv.parent()), socketCAN(rcv.socketCAN), ifr(rcv.ifr), addr(rcv.addr), speed_data(rcv.speed_data){}

Receiver Receiver::operator=(const Receiver& rcv){
    this->socketCAN = rcv.socketCAN;
    this->addr = rcv.addr;
    this->ifr = rcv.ifr;
    this->speed_data = rcv.speed_data;

    return * this;
}

int Receiver::initialize(){
    // Step 1: Create a CAN raw socket
    this-> socketCAN = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (socketCAN < 0) {
        qWarning() << "Error while creating CAN socket:" << strerror(errno);
        return FAILED;
    }

    // Step 2: Specify the CAN interface you want to use (can0)
    std::memset(&ifr, 0, sizeof(ifr));
    std::strcpy(ifr.ifr_name, "can0");
    if (ioctl(socketCAN, SIOCGIFINDEX, &ifr) < 0) {
        qWarning() << "Error getting interface index for 'can0':" << strerror(errno);
        return FAILED;
    }

    // Step 3: Bind the socket to the CAN interface
    std::memset(&addr, 0, sizeof(addr));
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(socketCAN, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        qWarning() << "Error binding CAN socket:" << strerror(errno);
        return FAILED;
    }

    return SUCCEDED;
}

void Receiver::run(){
    struct can_frame frame;

    qDebug() << "listening for CAN messages on can0...\n";

    while (true) {
        int nbytes = read(socketCAN, &frame, sizeof(struct can_frame));
        if (nbytes < 0) {
            qDebug() << "Error reading CAN frame!\n";
            return;
        } else if (nbytes != sizeof(struct can_frame)) {
            qWarning() << "Incomplete CAN frame received, size:" << nbytes;
            continue;
        }

        // Only handle expected CAN ID
        const canid_t expectedId = 0x631;
        if ((frame.can_id & CAN_EFF_FLAG) == 0 && (frame.can_id & CAN_SFF_MASK) != expectedId) {
            continue;
        }

        // bytes [0..1] contain big-endian uint16: (cm/s * 100)
        uint16_t rawSpeed = (static_cast<uint16_t>(frame.data[0]) << 8) |
                            static_cast<uint16_t>(frame.data[1]);
        float speedCms = static_cast<float>(rawSpeed) / 100.0f; // cm/s
        float speedKmh = speedCms * 0.036f;                     // km/h
        float scaledSpeedKmh = speedKmh * 10.0f;                // Arduino tops at 255, scale up for UI

        speed_prev = speed_data.speed_kmh;
        speed_data.speed_kmh = scaledSpeedKmh;
        speed_data.speed_kmh = EMA(); // smooth

        qDebug() << "ID:0x" << hex << frame.can_id
                 << "dlc:" << frame.can_dlc
                 << "data:"
                 << frame.data[0] << frame.data[1] << frame.data[2] << frame.data[3]
                 << frame.data[4] << frame.data[5] << frame.data[6] << frame.data[7];
        qDebug() << "raw(cm/s*100):" << rawSpeed
                 << "converted km/h before EMA:" << speedKmh
                 << "scaled x10 km/h:" << scaledSpeedKmh
                 << "after EMA:" << speed_data.speed_kmh;
        emit speedReceived(speed_data.speed_kmh);   // final speed value?

        // Step 5: Process received CAN message
        qDebug() << "Received CAN ID: " << frame.can_id << '\n';
        qDebug() << "Data: " << speed_data.speed_kmh << '\n';
    }
}

float Receiver::EMA(){
    return SMOOTHING_FACTOR * speed_data.speed_kmh + (1 - SMOOTHING_FACTOR) * speed_prev;
}
