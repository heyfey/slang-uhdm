// § selRootIpsOpFoldChainName264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, output logic [7:0] sh [M]);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      logic [STIDW-1:0] q;
      assign q = j;
      assign sh[i*2+j] = { h[i*2+j].a_source[0+:(IDW-STIDW)], q };
    end
  end
endmodule
module top(input tp::h2d_t [3:0] h, output logic [7:0] sh [4]);
  sock #(.M(4)) u(.h(h), .sh(sh));
endmodule
