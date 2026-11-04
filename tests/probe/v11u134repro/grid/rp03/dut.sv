// § pkgTsRefObjChainName134
package p;
  parameter int N = 4;
  typedef struct packed { logic [N-1:0] f; logic [N:0] g; } s_t;
endpackage
module top(input logic [8:0] i, output logic [3:0] o);
  import p::*;
  s_t s;
  assign s = i;
  assign o = s.f;
endmodule
