// § anonMemberRefChainName134
package p;
  typedef struct packed {
    struct packed { logic [1:0] a; logic b; } hdr;
    logic [3:0] body;
  } pkt_t;
  parameter pkt_t DEF = '{hdr: '{a: 2'b01, b: 1'b1}, body: 4'h5};
endpackage
module top(output logic [1:0] o);
  import p::*;
  assign o = DEF.hdr.a;
endmodule
