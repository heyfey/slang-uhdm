// § selRootIpsOpFoldChainName264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, input tp::h2d_t d, output logic [7:0] x [M], output logic [M-1:0] rv);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  tp::h2d_t [M-1:0] q;
  tp::h2d_t r;
  for (genvar i = 0; i < M; i++) begin : g
    assign q[i].a_source[0+:(IDW-STIDW)] = h[i].a_source[2+:(IDW-STIDW)];
    assign q[i].a_source[IDW-1-:STIDW] = '0;
    assign q[i].v = 1'b0;
    assign x[i] = q[i].a_source;
    assign rv[i] = r.v;
  end
  assign r.a_source[0+:(IDW-STIDW)] = '0;
  assign r.a_source[IDW-1-:STIDW] = '0;
  assign r.v = 1'b1;
endmodule
module top(input tp::h2d_t [3:0] h, input tp::h2d_t d, output logic [7:0] x [4], output logic [3:0] rv);
  sock #(.M(4)) u(.h(h), .d(d), .x(x), .rv(rv));
endmodule
