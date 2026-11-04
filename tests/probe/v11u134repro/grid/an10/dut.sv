// § anonMemberRefChainName134
package p;
  typedef union packed {
    struct packed { logic [1:0] hi; logic [1:0] lo; } parts;
    logic [3:0] whole;
  } u_t;
endpackage
module top(input logic [3:0] i, output logic [1:0] o);
  import p::*;
  u_t u;
  assign u.whole = i;
  assign o = u.parts.hi;
endmodule
