// § queueMemberSpanToDim212 — verifier: a queue member whose element is a package typedef, used by a module variable (both views)
package p;
  typedef logic [7:0] byte_t;
  typedef struct {
    byte_t data[$];
    int id;
  } pkt_t;
endpackage
module dut(input logic i, output logic o);
  p::pkt_t pk;
  initial pk.id = 1;
  assign o = i;
endmodule
