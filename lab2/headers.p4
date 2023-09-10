header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header vlan_t {
  bit<3>  pcp;
  bit<1>  dei;
  bit<12> vlanId;
  bit<16> etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header ipv6_t {
  bit<4>  version;
  bit<6>  dscp;
  bit<2>  ecn;
  bit<20> flowLabel;
  bit<16> payloadLength;
  bit<8>  nextHeader;
  bit<8>  hopLimit;
  bit<64> srcAddr;
  bit<64> dstAddr;
}

header udp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<16> hdrLength;
  bit<16> checksum;
}

header tcp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<32> seqNo;
  bit<32> ackNo;
  bit<4> dataOffset;
  bit<4> res;
  bit<8> flags;
  bit<16> window;
  bit<16> checksum;
  bit<16> urgentPtr;
}

struct headers_t {
    ethernet_t ethernet;
    vlan_t     vlan;
    ipv4_t     ipv4;
    ipv6_t     ipv6;
    ipv4_t     innerIpv4;
    tcp_t      tcp;
    udp_t      udp;
}

struct metadata_t {
    bool    validated;
    bool    decap;
    bool    rewrite;
    bool    forward;
    bit<12> vlan;
    bit<8>  l3Protocol;
    bit<16> l4SrcPort;
    bit<16> l4DstPort;
    bit<48> newDstAddr;
    bit<9>  egressPort;
}