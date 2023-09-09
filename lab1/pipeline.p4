/* `Validate` checks that the packet is well-formed. It is typically used
 * to check that the packets arriving on each port have the VLAN associated, 
 * with that port and that headers have the expected format -- e.g., if 
 * headers.innerIpv4 is valid then headers.ipv6 is too.
 */
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

/* `Route` determines the output port for IPv4 and IPv6 packets and
 * populates the user-defined metadata with the corresponding packet
 * modifications.
 */
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
        metadata.newDstAddr = dstAddr;
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
        // TODO: apply the ipv4Route, ipv6Route, and decap tables on
        // packets with the appropriate types.
    }
}

/* 'Acl` drops packets according to control-plane specified policies. 
 * The `acl` table can match against most L2-L4 headers
 */
control Acl (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    action allow() { }
    
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

/* `Rewrite` implements tunnel decapsulation and any rewrites specified in 
 * the user-defined metadata. 
 * - For decapsulation, we need to set IPv4 header to valid, copy the Inner 
 *   IPv4 header, and set the EtherType to 0x0800. 
 * - For the other rewrites, we need to copy the new Ethernet destination
 *   address and decrement the time-to-live field for IPv4 and IPv6. If the 
 *   time-to-live field is 0, the packet should be dropped.
*/
control Rewrite (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {

    apply {
        //TODO: implement tunnel decapsulation and rewrites.
    }
}

/* 'Forward' uses the `tag` table to optionally add a VLAN tag to the packet, 
 * and then sets the output port. */
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

/* `MyIngress` implements the full packet-processing pipeline. */
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
        // By default, the packet is dropped. 
        mark_to_drop(standard_metadata);
        validate.apply(headers, metadata, standard_metadata)
        // TODO: implement the rest of the pipeline, by invoking the
        // above controls, threading the same arguments through.
    }
}

control MyEgress (
    inout headers_t headers,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata) {
    
    apply {  }
}
