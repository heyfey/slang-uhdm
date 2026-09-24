// r11u61 h1 — THE CORPUS MIRROR at the ELABORATED MODULE COPY face.
// p1::K is an UNPACKED struct package localparam that the DECLARING PACKAGE's
// own scope member-selects (K.A / K.B in a typedef dim), so every DEF import
// copy is flat (pass 59).  The question this arm asks is what golden writes
// for the ELABORATED module/interface copies' operand SIZES.
// The three members are deliberately the SAME width (int unsigned, 32) so that
// this arm tests exactly one thing -- unsized-64 versus member-32 -- and h2/h3
// carry the differing-width sweep.
package p1;
  typedef struct { int unsigned A; int unsigned B; int unsigned C; } t1;
  localparam t1 K = '{A:1, B:2, C:3};
  typedef struct packed {
    logic [K.A-1:0] a;
    logic [K.B-1:0] b;
    logic [K.C-1:0] c;
  } w1;
endpackage

interface if1 import p1::*; (input logic clk);
  w1 w;
endinterface

module h1sub import p1::*; (if1 i, input logic clk);
  // a MODULE-LOCAL unpacked struct param, same shape, never package-selected
  localparam t1 L = '{A:4, B:5, C:6};
  wire x = i.w[0] & clk;
endmodule

module h1 import p1::*; (input logic clk);
  localparam t1 M = '{A:7, B:8, C:9};
  if1 a (.clk(clk));
  if1 b (.clk(clk));
  h1sub u (.i(a), .clk(clk));
  h1sub v (.i(b), .clk(clk));
endmodule
