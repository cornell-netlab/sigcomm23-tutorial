control MyVerifyChecksum(inout headers_t headers, inout metadata_t metadata) {
    apply {
        verify_checksum(headers.ipv4.isValid(), {
                headers.ipv4.version,
                headers.ipv4.ihl,
                headers.ipv4.diffserv,
                headers.ipv4.totalLen,
                headers.ipv4.identification,
                headers.ipv4.flags,
                headers.ipv4.fragOffset,
                headers.ipv4.ttl,
                headers.ipv4.protocol,
                headers.ipv4.srcAddr,
                headers.ipv4.dstAddr
            },
            headers.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }    
}

control MyUpdateChecksum(inout headers_t headers, inout metadata_t metadata) {
     apply {
	update_checksum(
	    headers.ipv4.isValid(),
            { headers.ipv4.version,
	      headers.ipv4.ihl,
              headers.ipv4.diffserv,
              headers.ipv4.totalLen,
              headers.ipv4.identification,
              headers.ipv4.flags,
              headers.ipv4.fragOffset,
              headers.ipv4.ttl,
              headers.ipv4.protocol,
              headers.ipv4.srcAddr,
              headers.ipv4.dstAddr },
            headers.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}
