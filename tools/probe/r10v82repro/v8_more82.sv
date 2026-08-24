// v82 adversarial arm V8 — the remaining chain shapes: an UNTYPED actual with a
// BASED initialiser, a NINE-hop name chain (past the depth guard), an actual
// naming a PACKAGE parameter with an EXPRESSION initialiser into a NARROW
// formal, an `integer` actual, and an actual that is a package parameter which
// is itself named by another package parameter.  MEASUREMENT ONLY.
package pkv8_82;
  localparam int  PEXPR = 4 + 4;
  localparam byte PB    = 8;
  localparam int  PALIAS = PB;
endpackage

typedef struct packed { logic [3:0] a; } mv8_t;

module leaf_v8 #(parameter byte LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_x;  mv8_t [LW:0] v_x;
  assign o = clk ^ n_x[0] ^ v_x[0].a[0];
endmodule
module leafi_v8 #(parameter int LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_y;  mv8_t [LW:0] v_y;
  assign o = clk ^ n_y[0] ^ v_y[0].a[0];
endmodule

module h1_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h2_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h2_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h3_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h3_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h4_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h4_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h5_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h5_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h6_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h6_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h7_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h7_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h8_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h8_v8 #(parameter int W = 1) (input logic clk, output logic o);
  h9_v8 #(.W(W)) i (.clk(clk), .o(o));
endmodule
module h9_v8 #(parameter byte W = 1) (input logic clk, output logic o);
  logic [W:0] n_h;  mv8_t [W:0] v_h;
  assign o = clk ^ n_h[0] ^ v_h[0].a[0];
endmodule

module top_v8_82 (input logic clk, output logic o1, o2, o3, o4, o5, o6);
  localparam      UNT_BASED = 8'd8;   // UNTYPED with a BASED initialiser
  localparam integer INTEGER_LP = 8;  // `integer` (32, 4-state)
  localparam byte    BYTE_LP = 8;
  leaf_v8  #(.LW(UNT_BASED))        i1 (.clk(clk), .o(o1));
  leafi_v8 #(.LW(pkv8_82::PEXPR))   i2 (.clk(clk), .o(o2));
  leaf_v8  #(.LW(pkv8_82::PEXPR))   i3 (.clk(clk), .o(o3));
  leafi_v8 #(.LW(INTEGER_LP))       i4 (.clk(clk), .o(o4));
  leaf_v8  #(.LW(pkv8_82::PALIAS))  i5 (.clk(clk), .o(o5));
  h1_v8    #(.W(BYTE_LP))           i6 (.clk(clk), .o(o6));
endmodule
