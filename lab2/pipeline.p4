control Validate (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    action setValidated() {
#ifdef P4_TESTGEN
        testgen_assume(!headers.vlan.isValid());
#endif        
        metadata.validated = true;
    }

    action setValidatedAndUntag() {
#ifdef P4_TESTGEN
        testgen_assume(headers.vlan.isValid());
#endif        
        metadata.validated = true;
        metadata.vlan = headers.vlan.vlanId;
        headers.ethernet.etherType = headers.vlan.etherType;
        headers.vlan.setInvalid();        
    }

    table validate {
        key = {
            standard_metadata.ingress_port: exact;
            headers.ethernet.etherType : exact;
            headers.vlan.vlanId : ternary;
            headers.vlan.etherType : ternary;
            headers.vlan.isValid() : exact;
            headers.ipv4.isValid() : exact;
            headers.ipv6.isValid() : exact;
            headers.innerIpv4.isValid() : exact;
        }
        actions = { setValidated; setValidatedAndUntag; NoAction; }
        default_action = NoAction();
    }

    apply {
        validate.apply();
    }
}

control Route (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    action setForwarding(bit<48> dstAddr, bit<9> egressPort) {
#ifdef P4_TESTGEN
        testgen_assume(0 < egressPort && egressPort <= 64);
#endif
        metadata.rewrite = true;
        metadata.forward = true;
        headers.ethernet.dstAddr = dstAddr;
        metadata.egressPort = egressPort;
    }
    
    table ipv4Route {
        key = {
            headers.ipv4.dstAddr : ternary;
        }
        actions = {
            setForwarding;
            NoAction;
        }
        default_action = NoAction();
    }

    table ipv6Route {
        key = {
            headers.ipv6.dstAddr : ternary;
        }
        actions = {
            setForwarding;
            NoAction;
        }
        default_action = NoAction();
    }

    action setDecap() {
        metadata.decap = true;
    }
    
    table decap {
        key = {
            headers.ipv6.dstAddr : ternary;           
        }
        actions = { setDecap; NoAction; }
        default_action = NoAction();
    }
        
    apply {
        if(headers.ipv4.isValid()) {
            ipv4Route.apply();
        }
        if(headers.ipv6.isValid()) {
            ipv6Route.apply();
            if (metadata.l3Protocol == 0x04) {
                decap.apply();
            }
        }
    }
}

control Acl (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    action allow() {
        metadata.forward = true;
    }

    action deny() {
        metadata.forward = false;
    }

    table acl {
        key = {
            standard_metadata.ingress_port : ternary;
            metadata.egressPort : ternary;
            metadata.vlan : ternary;
            headers.ethernet.srcAddr : exact;
            headers.ethernet.dstAddr : exact;
            headers.ethernet.etherType : exact;
            headers.ipv4.srcAddr : ternary;
            headers.ipv4.dstAddr : ternary;
            headers.ipv4.ttl : ternary;
            headers.ipv6.srcAddr : ternary;
            headers.ipv6.dstAddr : ternary;
            headers.ipv6.hopLimit : ternary;
            metadata.l3Protocol : ternary;
            metadata.l4SrcPort : ternary;
            metadata.l4DstPort : ternary;
        }
        actions = { allow; deny; }
        default_action = deny();
    }
    
    apply {
        acl.apply();
    }
}

control Rewrite (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {

    apply {
        if (metadata.decap) {
            headers.ipv4.setValid();
            headers.ipv4 = headers.innerIpv4;
            headers.ethernet.etherType = 0x0800;
            headers.ipv6.setInvalid();            
        }        
        
        if (metadata.rewrite) {
            if (headers.ipv4.isValid()) {
                headers.ipv4.ttl = headers.ipv4.ttl - 1;
                if (headers.ipv4.ttl == 0) { 
                    metadata.forward = false;
                } 
            } else if (headers.ipv6.isValid()) {
                headers.ipv6.hopLimit = headers.ipv6.hopLimit - 1;
                if (headers.ipv6.hopLimit == 0) {
                    metadata.forward = false;
                } 
            }
        }
    }
}

control Forward (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {

    action setTag(bit<12> vlanId) {
        headers.vlan.setValid();
	headers.vlan.pcp = 0;
	headers.vlan.dei = 0;
        headers.vlan.vlanId = vlanId;
        headers.vlan.etherType = headers.ethernet.etherType;
        headers.ethernet.etherType = 0x8100;
    }
    
    table tag {
        key = {
            standard_metadata.ingress_port: exact;
        }
        actions = { setTag; NoAction; }
        default_action = NoAction();
    }

    apply {
        if (metadata.forward) {
           tag.apply();
	   standard_metadata.egress_spec = metadata.egressPort;
        }
    }
}
        
control MyIngress (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {

    Validate() validate;
    Route() route;
    Acl() acl;
    Rewrite() rewrite;
    Forward() forward;

    apply {
        mark_to_drop(standard_metadata);
        validate.apply(headers, metadata, standard_metadata);
        if(metadata.validated) {
            route.apply(headers, metadata, standard_metadata);
            acl.apply(headers, metadata, standard_metadata);
            rewrite.apply(headers, metadata, standard_metadata);
            forward.apply(headers, metadata, standard_metadata);
        }
    }
}

control MyEgress (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    apply {  }
}
