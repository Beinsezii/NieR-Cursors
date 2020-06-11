#!/usr/bin/python3
import argparse
import struct


def icotocur(buff, hotx, hoty):
    """Updates buff from ico to cur format with hotpots as a multiplier."""
    assert 0 <= hotx <= 1 and 0 <= hoty <= 1
    buff = bytearray(buff)
    buff[2:4] = struct.pack('H', 2)
    first_offset = struct.unpack('<HHHBBBBHHII', buff[:22])[10]
    for x in range(6, first_offset, 16):
        props = list(struct.unpack('<BBBBHHII', buff[x:x + 16]))
        props[4] = int(round(props[0] * hotx))
        props[5] = int(round(props[0] * hoty))
        buff[x:x + 16] = struct.pack('<BBBBHHII', *props)
    return bytes(buff)


def main():
    parser = argparse.ArgumentParser(description="Convert ico files to cur files.")
    parser.add_argument('input', type=str)
    parser.add_argument("hotx", type=float, help="0.0 <= hotx <= 1.0")
    parser.add_argument("hoty", type=float, help="0.0 <= hoty <= 1.0")
    parser.add_argument('output', type=str)
    args = parser.parse_args()

    infile = open(args.input, mode='rb')
    outfile = open(args.output, mode='wb')

    outfile.write(icotocur(infile.read(), args.hotx, args.hoty))
    infile.close()
    outfile.close()


if __name__ == "__main__":
    main()
