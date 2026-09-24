// r10v77 -- ADVERSARIAL grid J: DRIVENNESS and CONNECTION SHAPE around the law.
// A multiply-driven inout, a tri net, a port connected to a CONSTANT, to an
// EXPRESSION, to a part-select, and left UNCONNECTED.
package j77;
  typedef logic [7:0] v8_t;
endpackage

module leafJ (
  inout  j77::v8_t   j_io,
  input  j77::v8_t   j_in,
  output j77::v8_t   j_out
);
  assign j_out = j_in;
endmodule

module drvJ (inout j77::v8_t d_io);
  assign d_io = 8'hAA;
endmodule

module topJ;
  tri  [7:0] t;
  wire [7:0] w;
  logic [7:0] s, r;
  assign w = 8'h55;
  leafJ u_j1 (.j_io(t), .j_in(8'h0F),        .j_out(s));      // CONSTANT actual
  leafJ u_j2 (.j_io(t), .j_in(s ^ r),        .j_out());       // EXPRESSION actual, unconnected out
  leafJ u_j3 (.j_io(w), .j_in(r[7:0]),       .j_out());       // part-select actual
  leafJ u_j4 (.j_io(),  .j_in(),             .j_out());       // ALL unconnected
  drvJ  u_d1 (.d_io(t));
  drvJ  u_d2 (.d_io(t));                                      // second driver
endmodule
