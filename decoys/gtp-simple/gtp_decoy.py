#!/usr/bin/env python3
# gtp-c decoy service - phase 1
# listens udp 2123, responds to gtp echo requests, logs to syslog

import socket
import syslog
import struct

UDP_PORT = 2123

def parse_gtp(data):
    if len(data) < 8:
        return None
    return {
        'version': (data[0] >> 5) & 0x7,
        'msg_type': data[1],
        'length': struct.unpack('!H', data[2:4])[0],
        'teid': struct.unpack('!I', data[4:8])[0]
    }

def echo_response(teid):
    flags = 0x40  # version 1, GTP-C
    msg_type = 0x02  # echo response
    ie = bytes([14, 0])  # recovery IE type=14 value=0
    length = 4 + len(ie)
    return struct.pack('!BBHI', flags, msg_type, length, teid) + ie

def main():
    syslog.openlog('gtp-decoy', syslog.LOG_PID, syslog.LOG_LOCAL0)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', UDP_PORT))
    syslog.syslog(syslog.LOG_INFO,
        f'CEF:0|TSO-Security|GTP-Decoy|1.0|start|GTP Decoy Started|3|'
        f'dpt={UDP_PORT} msg=listening')

    while True:
        try:
            data, (src_ip, src_port) = sock.recvfrom(4096)
            hdr = parse_gtp(data)

            if hdr and hdr['msg_type'] == 0x01:
                # valid gtp echo request - respond
                sock.sendto(echo_response(hdr['teid']), (src_ip, src_port))
                syslog.syslog(syslog.LOG_WARNING,
                    f'CEF:0|TSO-Security|GTP-Decoy|1.0|gtp_echo|GTP Echo Request|6|'
                    f'src={src_ip} spt={src_port} dpt={UDP_PORT} '
                    f'gtp_version={hdr["version"]} teid={hdr["teid"]} '
                    f'msg=echo_response_sent')
            elif hdr:
                # valid gtp but not echo - log only
                syslog.syslog(syslog.LOG_WARNING,
                    f'CEF:0|TSO-Security|GTP-Decoy|1.0|gtp_packet|GTP Packet Received|5|'
                    f'src={src_ip} spt={src_port} dpt={UDP_PORT} '
                    f'gtp_version={hdr["version"]} msg_type={hdr["msg_type"]} '
                    f'teid={hdr["teid"]} bytes={len(data)}')
            else:
                # non-gtp udp hit
                syslog.syslog(syslog.LOG_WARNING,
                    f'CEF:0|TSO-Security|GTP-Decoy|1.0|udp_hit|UDP Probe Received|4|'
                    f'src={src_ip} spt={src_port} dpt={UDP_PORT} '
                    f'bytes={len(data)} msg=non_gtp_packet')

        except Exception as e:
            syslog.syslog(syslog.LOG_ERR,
                f'CEF:0|TSO-Security|GTP-Decoy|1.0|error|GTP Decoy Error|2|'
                f'msg={str(e)}')

if __name__ == '__main__':
    main()
