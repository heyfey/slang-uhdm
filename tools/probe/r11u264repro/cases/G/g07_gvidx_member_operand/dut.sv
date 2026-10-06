// § selRootIpsOpFoldChainName264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] tl_h_i, input tp::h2d_t d, input logic [7:0] w [M], output logic [7:0] x [M], output logic [M-1:0] rv);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < M; i++) begin : g
    assign x[i] = tl_h_i[i].a_source[0+:STIDW] & 8'h3;
    assign rv[i] = 1'b0;
  end
endmodule
module top(input tp::h2d_t [3:0] h, input tp::h2d_t d, input logic [7:0] w [4], output logic [7:0] x [4], output logic [3:0] rv);
  sock #(.M(4)) u(.tl_h_i(h), .d(d), .w(w), .x(x), .rv(rv));
endmodule
