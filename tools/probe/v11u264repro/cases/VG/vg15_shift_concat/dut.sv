// § selRootIpsOpFoldChainName264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, output logic [7:0] sh [M]);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < M; i++) begin : g
    logic [STIDW-1:0] q;
    assign q = i;
    assign sh[i] = { h[i].a_source[0+:(IDW>>1) + (STIDW<<1) - STIDW], q };
  end
endmodule
module top(input tp::h2d_t [3:0] h, output logic [7:0] sh [4]);
  sock #(.M(4)) u(.h(h), .sh(sh));
endmodule
