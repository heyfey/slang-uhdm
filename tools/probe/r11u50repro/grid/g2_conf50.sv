// r11u50 grid g2 -- THE SHAPES WHERE § dimRedCtExpr79's TABLE AND THE OLD
// `paramIntEnc` MARKER DISAGREE, plus the abstention shapes.  Same read as g1:
// `logic [<P>-1:0] dNN;`, the DEF listing's `vpiOpType:11` leaf.
package q50;
  parameter int unsigned A32 = 32;
  parameter int unsigned B8  = 8;
  parameter int unsigned C3  = 3;

  parameter int unsigned M_SHD = (A32 / B8) << 1;   // d01 SHIFT over a divide
  parameter int unsigned M_SHS = (A32 - B8) >> 1;   // d02 SHIFT over a subtract
  parameter int unsigned M_AND = A32 & 60;          // d03 a bitwise AND
  parameter int unsigned M_ANS = (A32 - B8) & 60;   // d04 bitwise over a subtract
  parameter int unsigned M_NEG = -B8;               // d05 a bare unary minus (+40 below)
  parameter int unsigned M_UPW = A32 ** 1;          // d06 an UNSIGNED power
  parameter int unsigned M_VEC = 32'd40 - 8;        // d07 a DEC vector literal operand
  parameter int unsigned M_HEX = 32'h28;            // d08 a HEX vector literal alone
  parameter int unsigned M_XOR = A32 ^ 60;          // d09 XOR -- the table ABSTAINS
  parameter int unsigned M_CMP = (A32 > B8) + 39;   // d10 a comparison -- ABSTAINS
  parameter int unsigned M_CAT = {8'd0, 8'd40};     // d11 a concat -- ABSTAINS
  parameter int unsigned M_CST = int'(A32 - B8);    // d12 a CAST over a subtract
  parameter int unsigned M_TRN = A32 ? 40 : 8;      // d13 a conditional -- ABSTAINS
  parameter int unsigned M_CHN = M_SHD + 24;        // d14 an add over d01
  parameter int unsigned M_CHM = M_AND + 8;         // d15 an add over d03
  parameter int unsigned M_BIT = $bits(A32) + 8   ;// d16 $bits
  parameter int unsigned M_MUL = 5 * 8;             // d17 a pure literal multiply
endpackage

module n50 import q50::*; (input logic clk);
  logic [M_SHD-1:0] d01;
  logic [M_SHS-1:0] d02;
  logic [M_AND-1:0] d03;
  logic [M_ANS-1:0] d04;
  logic [M_NEG+40-1:0] d05;
  logic [M_UPW-1:0] d06;
  logic [M_VEC-1:0] d07;
  logic [M_HEX-1:0] d08;
  logic [M_XOR-1:0] d09;
  logic [M_CMP-1:0] d10;
  logic [M_CAT-1:0] d11;
  logic [M_CST-1:0] d12;
  logic [M_TRN-1:0] d13;
  logic [M_CHN-1:0] d14;
  logic [M_CHM-1:0] d15;
  logic [M_BIT-1:0] d16;
  logic [M_MUL-1:0] d17;
endmodule

module tb51;
  logic clk;
  n50 u (.clk(clk));
endmodule
