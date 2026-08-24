// v82 adversarial arm V6 — THE FENCE HOLES.  Every cell is a shape where the
// OLD `litBoundOwnPar9` lent the FORMAL's width and the NEW
// `ovActualStoredWidth82` ABSTAINS (returns 64) or answers a DIFFERENT width.
// If golden ever agreed with the FORMAL's width, the patch is a REGRESSION on
// legal SV.  The formal is deliberately given the ACTUAL's width in each pair.
// MEASUREMENT ONLY.
package pkv6_82;
  localparam byte PBYTE = 8;
endpackage

typedef struct packed { logic [3:0] a; } mv6_t;

module w100_v6 #(parameter logic [99:0] LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_a;  mv6_t [LW:0] v_a;
  assign o = clk ^ n_a[0] ^ v_a[0].a[0];
endmodule
module wbyte_v6 #(parameter byte LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_b;  mv6_t [LW:0] v_b;
  assign o = clk ^ n_b[0] ^ v_b[0].a[0];
endmodule
module wshort_v6 #(parameter shortint LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_c;  mv6_t [LW:0] v_c;
  assign o = clk ^ n_c[0] ^ v_c[0].a[0];
endmodule
module wnib_v6 #(parameter bit [3:0] LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_d;  mv6_t [LW:0] v_d;
  assign o = clk ^ n_d[0] ^ v_d[0].a[0];
endmodule

module top_v6_82 (input logic clk,
                  output logic o1, o2, o3, o4, o5, o6, o7, o8);
  localparam logic [99:0] WIDE100 = 8;   // width 100  (formal is also 100)
  localparam              UNT_LIT = 8;   // UNTYPED, literal init
  localparam int          BASED_I = 8'd8;
  localparam byte         BASED_B = 8'd8;
  localparam shortint     BASED_S = 16'd8;
  localparam bit [3:0]    BASED_N = 4'h7;
  // 1  formal 100 <- actual 100, literal init:  OLD 100, NEW 64
  w100_v6  #(.LW(WIDE100)) i1 (.clk(clk), .o(o1));
  // 2  formal byte <- actual UNTYPED literal:   OLD 8,  NEW 32
  wbyte_v6 #(.LW(UNT_LIT)) i2 (.clk(clk), .o(o2));
  // 3  formal byte <- actual int BASED init:    OLD 8,  NEW 64
  wbyte_v6 #(.LW(BASED_I)) i3 (.clk(clk), .o(o3));
  // 4  formal byte <- actual byte BASED init:   OLD 8,  NEW 64
  wbyte_v6 #(.LW(BASED_B)) i4 (.clk(clk), .o(o4));
  // 5  formal shortint <- actual shortint BASED: OLD 16, NEW 64
  wshort_v6 #(.LW(BASED_S)) i5 (.clk(clk), .o(o5));
  // 6  formal bit[3:0] <- actual bit[3:0] BASED: OLD 4, NEW 64
  wnib_v6  #(.LW(BASED_N)) i6 (.clk(clk), .o(o6));
  // 7  formal 100 <- actual byte:               OLD 100, NEW 8
  w100_v6  #(.LW(pkv6_82::PBYTE)) i7 (.clk(clk), .o(o7));
  // 8  formal byte <- actual 100:               OLD 8,   NEW 64
  wbyte_v6 #(.LW(WIDE100)) i8 (.clk(clk), .o(o8));
endmodule
