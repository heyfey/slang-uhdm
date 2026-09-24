// § anonMemberRefChainName134
package p;
  typedef struct packed {
    struct packed { logic [1:0] a; logic b; } hdr;
    logic [3:0] body;
  } pkt_t;
endpackage
module top(input logic c, output logic [1:0] o);
  import p::*;
  pkt_t k;
  always_comb begin k = '0; k.hdr.a = {c, c}; end
  assign o = k.hdr.a;
endmodule
