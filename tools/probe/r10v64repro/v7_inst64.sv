// r10v64 ARM 7 — ONE definition, THREE instances with DIFFERENT overrides
// (the per-instance copy the law claims), plus a two-level hierarchy where the
// inner override is the outer parameter, and a same-override pair (the copy
// must not leak between instances).  MEASUREMENT ONLY.
module innerV7 #(parameter int unsigned P = 4)(input c, input [7:0] n, output [3:0] y);
  localparam int unsigned W = 4;
  if (P != 0) begin : g_if
    wire [3:0] q0, q1, q2;
    assign q0 = c ? P : P;
    assign q1 = W'(P);
    assign q2 = n[P +: 1] | 4'd0;
    assign y  = q0 ^ q1 ^ q2;
  end
  else begin : g_e assign y = 4'd0; end
endmodule

module outerV7 #(parameter int unsigned OP = 4)(input c, input [7:0] n, output [3:0] y);
  innerV7 #(.P(OP))     i_pass (c, n, y);   // inner override IS the outer param
endmodule

module topV7(input c, input [7:0] n);
  localparam int       SI = 1 * 2;
  localparam bit [3:0] SH = 4'h2;
  localparam bit [3:0] SB = 4'b0010;
  wire [3:0] y1,y2,y3,y4,y5,y6,y7,y8;
  innerV7 #(.P(2))  k1 (c, n, y1);
  innerV7 #(.P(SH)) k2 (c, n, y2);
  innerV7 #(.P(SB)) k3 (c, n, y3);
  innerV7 #(.P(2))  k4 (c, n, y4);   // same as k1 — must be an independent copy
  outerV7 #(.OP(2))  m1 (c, n, y5);
  outerV7 #(.OP(SH)) m2 (c, n, y6);
  outerV7 #(.OP(SB)) m3 (c, n, y7);
  outerV7            m4 (c, n, y8);  // default all the way down
endmodule
