// b09: literals arriving through macros, `include-free, plus escaped names,
// multi-declarator lists and a parameter whose init is an unsized literal
// with a leading/trailing space inside the token stream.
`define H 'h1a
`define B 'b1010
`define D 'd26
`define SZ 8'h1a
package b09_pkg;
  parameter MH = `H;
  parameter MB = `B;
  parameter MD = `D;
  parameter MS = `SZ;
  parameter L1 = 'h1, L2 = 'b10, L3 = 'd3, L4 = 'o4;
  parameter \esc$name = 'h5;
  parameter SP = 'h 1a;
endpackage
module b09_top;
  import b09_pkg::*;
  initial $display(MH, MB, MD, MS, L1, L2, L3, L4, \esc$name , SP);
endmodule
