// r11u50 grid g1 — THE ENCODING OF A WILDCARD-IMPORTED PACKAGE PARAMETER
// SUBSTITUTED AT AN OPERATION LEAF.  One package parameter per initializer
// SHAPE, each read once as `logic [<P>-1:0]` so the leaf lands under a
// vpiSubOp the producer does NOT fold.  ibex_pkg.sv:396's own shape is r03.
package p50;
  parameter int unsigned A32   = 32;
  parameter int unsigned B8    = 8;
  parameter int unsigned C3    = 3;
  parameter int          S32   = 32;

  parameter int unsigned L_LIT  = 22;               // r01 a bare literal
  parameter int unsigned L_SUB  = A32 - B8;         // r02 TOP-LEVEL subtract
  parameter int unsigned L_SBAD = A32 - B8 - C3 + 1;// r03 SUBTRACT UNDER AN ADD (ibex)
  parameter int unsigned L_ADD  = A32 + B8;         // r04 a plain add
  parameter int unsigned L_MUL  = B8 * C3;          // r05 multiply
  parameter int unsigned L_DIV  = A32 / B8;         // r06 divide
  parameter int unsigned L_MOD  = A32 % C3;         // r07 modulo
  parameter int unsigned L_CLOG = $clog2(A32);      // r08 a system call
  parameter int unsigned L_POW  = 2 ** C3;          // r09 power
  parameter int unsigned L_ADDR = 1 + (A32 - B8);   // r10 subtract on the RIGHT of an add
  parameter int unsigned L_ADDL = (A32 - B8) + 1;   // r11 subtract on the LEFT of an add
  parameter int unsigned L_PAR  = (A32 - B8);       // r12 a parenthesised subtract
  parameter int unsigned L_REF  = L_SUB;            // r13 a bare reference to an INT one
  parameter int unsigned L_RADD = L_SUB + 1;        // r14 an add over an INT one
  parameter int unsigned L_RUAD = L_ADD + 1;        // r15 an add over a UINT one
  parameter int unsigned L_CSUB = $clog2(A32) - 1;  // r16 subtract under a system call arg
  parameter int unsigned L_SCL  = A32 - $clog2(B8); // r17 subtract with a call operand
  parameter int unsigned L_NEG  = -B8 + 40;         // r18 a unary minus
  parameter int unsigned L_MSUB = (A32 - B8) * 2;   // r19 subtract under a multiply
  parameter int unsigned L_DSUB = (A32 - B8) / 2;   // r20 subtract under a divide
  parameter int          L_TINT = A32 - B8 - C3 + 1;// r21 the r03 shape, DECLARED int
  parameter              L_TUNT = A32 - B8 - C3 + 1;// r22 the r03 shape, UNTYPED
  parameter logic [31:0] L_TLOG = A32 - B8 - C3 + 1;// r23 the r03 shape, logic [31:0]
  parameter int unsigned L_SSUB = S32 - B8;         // r24 a SIGNED left operand
endpackage

module m50 import p50::*; (input logic clk);
  logic [L_LIT -1:0] c01;
  logic [L_SUB -1:0] c02;
  logic [L_SBAD-1:0] c03;
  logic [L_ADD -1:0] c04;
  logic [L_MUL -1:0] c05;
  logic [L_DIV -1:0] c06;
  logic [L_MOD -1:0] c07;
  logic [L_CLOG-1:0] c08;
  logic [L_POW -1:0] c09;
  logic [L_ADDR-1:0] c10;
  logic [L_ADDL-1:0] c11;
  logic [L_PAR -1:0] c12;
  logic [L_REF -1:0] c13;
  logic [L_RADD-1:0] c14;
  logic [L_RUAD-1:0] c15;
  logic [L_CSUB-1:0] c16;
  logic [L_SCL -1:0] c17;
  logic [L_NEG -1:0] c18;
  logic [L_MSUB-1:0] c19;
  logic [L_DSUB-1:0] c20;
  logic [L_TINT-1:0] c21;
  logic [L_TUNT-1:0] c22;
  logic [L_TLOG-1:0] c23;
  logic [L_SSUB-1:0] c24;
endmodule

module tb50;
  logic clk;
  m50 u (.clk(clk));
endmodule
