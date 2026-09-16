// r11v50 BREAK grid b1 — faces the pass's g1/g2 do NOT cover.
package q50;
  parameter int unsigned Q = 5 * 3;
endpackage

package p51;
  parameter int unsigned A32 = 32;
  parameter int unsigned B8  = 8;
  parameter int unsigned C3  = 3;
  parameter int          S32 = 32;
  parameter int          NEGV = -5;
  parameter int unsigned MUL2 = B8 * C3;

  function automatic int unsigned f51(input int unsigned x);
    f51 = x + 1;
  endfunction

  parameter int unsigned K_DEC   = 32'd40;             // b01 SIZED DECIMAL literal
  parameter int unsigned K_SDEC  = 32'sd40;            // b02 SIGNED sized decimal
  parameter int unsigned K_BIN   = 8'b101000;          // b03 binary literal
  parameter int unsigned K_NEGAD = NEGV + 45;          // b04 add over a unary-minus NAME
  parameter int unsigned K_XMUL  = q50::Q * 2;         // b05 cross-package multiply
  parameter int unsigned K_XREF  = q50::Q;             // b06 bare cross-package NAME
  parameter int unsigned K_MODSH = (A32 % B8) << 1;    // b07 shift over a MODULO
  parameter int unsigned K_POWU  = 2 ** 5;             // b08 both-literal power
  parameter int unsigned K_UMUL  = -(B8 * C3) + 64;    // b09 unary minus over a multiply
  parameter int unsigned K_ADDDC = 32'd32 + 8;         // b10 add with a SIZED-DECIMAL operand
  parameter int          K_NEGRS = 3 - 8;              // b11 a NEGATIVE folded result
  parameter int unsigned K_CAST  = int'(B8 * C3);      // b12 an explicit cast over a multiply
  parameter int unsigned K_UFN   = f51(B8 * C3);       // b13 a USER function call
  parameter int          K_SMUL  = S32 * 2;            // b14 declared int, signed operand
  parameter int signed   K_SIMUL = B8 * C3;            // b15 declared int SIGNED, multiply
  parameter logic signed [31:0] K_LSMUL = B8 * C3;     // b16 declared logic signed, multiply
  parameter int unsigned K_CHN2  = MUL2 + 1;           // b17 add over a MULTIPLY name
  parameter int unsigned K_DIVSR = (A32 / B8) >> 1;    // b18 right-shift over a divide
  parameter int unsigned K_SUBSH = (A32 - B8) << 1;    // b19 shift over a subtract
  parameter int unsigned K_NESTM = (A32 - B8) * (C3 + 1); // b20 multiply of two ops
endpackage

module m51 import p51::*; (input logic clk);
  logic [K_DEC  -1:0] c01;
  logic [K_SDEC -1:0] c02;
  logic [K_BIN  -1:0] c03;
  logic [K_NEGAD-1:0] c04;
  logic [K_XMUL -1:0] c05;
  logic [K_XREF -1:0] c06;
  logic [K_MODSH-1:0] c07;
  logic [K_POWU -1:0] c08;
  logic [K_UMUL -1:0] c09;
  logic [K_ADDDC-1:0] c10;
  logic [K_NEGRS+40-1:0] c11;
  logic [K_CAST -1:0] c12;
  logic [K_UFN  -1:0] c13;
  logic [K_SMUL -1:0] c14;
  logic [K_SIMUL-1:0] c15;
  logic [K_LSMUL-1:0] c16;
  logic [K_CHN2 -1:0] c17;
  logic [K_DIVSR-1:0] c18;
  logic [K_SUBSH-1:0] c19;
  logic [K_NESTM-1:0] c20;
endmodule

module tb51;
  logic clk;
  m51 u (.clk(clk));
endmodule
