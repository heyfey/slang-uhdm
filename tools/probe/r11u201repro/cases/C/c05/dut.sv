// § clsScopedBoundWholeSpan201
package p;
  class C;
    localparam int unsigned W = 5;
  endclass
endpackage
class K;
  localparam int unsigned V = 6;
  localparam int unsigned W = 1;
endclass
typedef struct packed { logic [15:0] f; } s_t;
module top (input s_t s, input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  assign y1 = s.f[K::V:0];
  assign y2 = x[p::C::W:K::W] + x[(K::V):0];
endmodule
