// r10v81 arm v3 — ACTUAL-EXPRESSION SHAPES around the folded index: a
// concatenation, an OUTPUT-port select, a hierarchical actual, a 2-D element
// select, a select inside a cast/ternary, and the earl71 KEEPS-REF controls in
// the same connection.  MEASUREMENT ONLY.
module leafv3 (input logic ib, input logic [3:0] iv, output logic o,
               output logic [3:0] ov);
  assign o = ib; assign ov = iv;
endmodule

module subv3 (output logic [15:0] sw);
  assign sw = 16'hABCD;
endmodule

module midv3 #(parameter int unsigned N = 1)
              (input logic [15:0] w, output logic [15:0] y);
  logic [15:0] mem2 [0:3];
  subv3 us ();
  // concatenation actual carrying the folded index
  leafv3 uCat (.ib(^{w[N], 1'b0}), .iv(w[3:0]), .o(y[0]), .ov());
  // OUTPUT port whose actual is a select with the same index
  leafv3 uOut (.ib(1'b0), .iv(w[3:0]), .o(y[N]), .ov());
  // HIERARCHICAL actual with the same index
  leafv3 uHier (.ib(us.sw[N]), .iv(w[3:0]), .o(y[2]), .ov());
  // 2-D: unpacked element select then bit select
  leafv3 u2D (.ib(mem2[1][N]), .iv(w[3:0]), .o(y[3]), .ov());
  // ternary / cast around the select
  leafv3 uTer (.ib(N > 0 ? w[N] : 1'b0), .iv(w[3:0]), .o(y[4]), .ov());
  leafv3 uCast (.ib(logic'(w[N])), .iv(w[3:0]), .o(y[5]), .ov());
  // earl71 KEEPS-REF controls, same connection
  leafv3 uPs  (.ib(1'b0), .iv(w[N+3:N]),  .o(y[6]), .ov());
  leafv3 uIps (.ib(1'b0), .iv(w[N +: 4]), .o(y[7]), .ov());
  initial mem2[1] = 16'h0;
endmodule

module topv3 (input logic [15:0] w, output logic [15:0] y);
  midv3 #(.N(2)) i0 (.w(w), .y(y));
endmodule
