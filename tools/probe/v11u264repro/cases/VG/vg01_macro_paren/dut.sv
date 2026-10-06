// § memberIpsParenEnd264
`define WW (IDW-STIDW)
`define BB (1)
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, input tp::h2d_t d, output logic [7:0] x [M], output logic [M-1:0] rv);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < M; i++) begin : g
    assign x[i] = h[i].a_source[0+:`WW] | d.a_source[`BB +: `WW];
    assign rv[i] = d.a_source[`BB];
  end
endmodule
module top(input tp::h2d_t [3:0] h, input tp::h2d_t d, output logic [7:0] x [4], output logic [3:0] rv);
  sock #(.M(4)) u(.h(h), .d(d), .x(x), .rv(rv));
endmodule
