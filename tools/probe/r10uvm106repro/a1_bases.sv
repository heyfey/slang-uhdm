// a1: one home (package), every literal form, untyped unranged parameter
package a1_pkg;
  parameter A_HEXBIG = 'hf000000;
  parameter A_HEX0   = 'h0;
  parameter A_BIN    = 'b101;
  parameter A_OCT    = 'o17;
  parameter A_DEC    = 'd13;
  parameter A_SHEX   = 'sh1;
  parameter A_SBIN   = 'sb101;
  parameter A_SOCT   = 'so7;
  parameter A_SDEC   = 'sd9;
  parameter A_HEXX   = 'hx;
  parameter A_BINZ   = 'bz;
  parameter A_HEXZ   = 'hz;
  parameter A_OCTX   = 'ox;
  parameter A_SIZED  = 32'hf000000;
  parameter A_SIZEDB = 3'b101;
  parameter A_SIZEDX = 3'bx;
  parameter A_PLAIN  = 13;
  parameter A_EXPR   = 'hf000000 + 1;
  parameter A_PAREN  = ('hf);
  parameter A_REF    = A_HEX0;
  parameter A_UNBASED = '0;
  localparam A_LHEX  = 'h1a;
  localparam A_LBIN  = 'b11;
endpackage
module a1_top;
  a1_use u1();
endmodule
module a1_use;
  import a1_pkg::*;
  initial $display(A_HEXBIG, A_BIN, A_DEC, A_LHEX);
endmodule
