// § pkgTsRefObjChainName134
package p;
  parameter int N = 4;
  typedef struct packed { logic [N-1:0] f; } s_t;
  typedef struct packed { s_t a; logic [N-2:0] b; } o_t;
endpackage
module top(input logic [6:0] i, output logic [3:0] o);
  p::o_t s;
  assign s = i;
  assign o = s.a.f;
endmodule
