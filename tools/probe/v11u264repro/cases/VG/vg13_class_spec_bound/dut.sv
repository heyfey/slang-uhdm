// § selRootIpsOpFoldChainName264
class cfg #(int N = 2);
  localparam int W = N * 2;
endclass
package tp;
  typedef struct packed { logic v; logic [7:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, output logic [7:0] sh [M]);
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < M; i++) begin : g
    assign sh[i] = { h[i].a_source[0+:(cfg#(3)::W - STIDW)], 4'h0 };
  end
endmodule
module top(input tp::h2d_t [3:0] h, output logic [7:0] sh [4]);
  sock #(.M(4)) u(.h(h), .sh(sh));
endmodule
