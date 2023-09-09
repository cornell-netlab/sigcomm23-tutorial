parser MyParser(packet_in packet,
                out headers_t headers,
                inout metadata_t metadata,
                inout standard_metadata_t standard_metadata) {

    state start {
        metadata.validated = false;
        metadata.decap = false;
        metadata.rewrite = false;
        metadata.forward = false;
        metadata.vlan = 0;
        metadata.l3Protocol = 0;
        metadata.l4SrcPort = 0;
        metadata.l4DstPort = 0;
        metadata.newDstAddr = 0;
        metadata.egressPort = 0;
        transition parseEthernet;
    }
    
    state parseEthernet {
        packet.extract(headers.ethernet);
        transition select(headers.ethernet.etherType) {
            0x0800: parseIpv4;
            0x86DD: parseIpv6;
            0x8100: parseVlan;
            default: accept;
        }
    }

    state parseVlan {
        packet.extract(headers.vlan);
        transition select(headers.vlan.etherType) {
            0x0800: parseIpv4;
            0x086DD: parseIpv6;
            default: accept;
        }
    }
   
    state parseIpv4 {
        packet.extract(headers.ipv4);
        metadata.l3Protocol = headers.ipv4.protocol;
        transition select(headers.ipv4.protocol) {
            0x06: parseTcp;
            0x11: parseUdp;
            default: accept; 
        }
    }

    state parseIpv6 {
        packet.extract(headers.ipv6);
        metadata.l3Protocol = headers.ipv6.nextHeader;
        transition select(headers.ipv6.nextHeader) {
            0x04: parseInnerIpv4;
            0x06: parseTcp;
            0x11: parseUdp;
            default: accept; 
        }
    }

    state parseInnerIpv4 {
        packet.extract(headers.innerIpv4);
        metadata.l3Protocol = headers.innerIpv4.protocol;
        transition select(headers.innerIpv4.protocol) {
            0x06: parseTcp;
            0x11: parseUdp;
            default: accept; 
        }
    }

    state parseTcp {
        packet.extract(headers.tcp);
        metadata.l4SrcPort = headers.tcp.srcPort;
        metadata.l4DstPort = headers.tcp.dstPort;
        transition accept;
    }

    state parseUdp {
        packet.extract(headers.udp);
        metadata.l4SrcPort = headers.udp.srcPort;
        metadata.l4DstPort = headers.udp.dstPort;
        transition accept;
    }    
}

control MyDeparser(packet_out packet, in headers_t headers) {
    apply {
        packet.emit(headers.ethernet);
        packet.emit(headers.vlan);
        packet.emit(headers.ipv4);
        packet.emit(headers.ipv6);
        packet.emit(headers.innerIpv4);
        packet.emit(headers.tcp);
        packet.emit(headers.udp);
    }
}
