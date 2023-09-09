#include <core.p4>
#include <v1model.p4>

#ifdef P4_TESTGEN
extern void testgen_assume(in bool check);
#endif

#include "headers.p4"
#include "parde.p4"
#include "checksums.p4"
#include "pipeline.p4"

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyUpdateChecksum(),
    MyDeparser()
) main;

