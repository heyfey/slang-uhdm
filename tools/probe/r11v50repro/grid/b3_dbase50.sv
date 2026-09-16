// r11v50 BREAK grid b3 — the `'d` BASE face the pass's fence paragraph claims
// is refused, plus the § patDefBoundPkgParamSubst (named-element array) site.
package r53;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } el_t;
  parameter int unsigned A32 = 32;
  parameter int unsigned B8  = 8;

  parameter int unsigned T_PLAIN = 40;            // e01 control: unsized literal
  parameter int unsigned T_DEC   = 32'd40;        // e02 SIZED DECIMAL
  parameter int unsigned T_UDEC  = 'd40;          // e03 UNSIZED-with-base decimal
  parameter int signed   T_SDECL = 32'd40;        // e04 declared SIGNED, sized decimal
  parameter int unsigned T_REFD  = T_DEC;         // e05 a NAME to a sized decimal
  parameter int unsigned T_HEX   = 32'h28;        // e06 sized HEX (control: abstain)
  parameter int unsigned T_NMUL  = A32 * 2;       // e07 multiply (control: moves)
  parameter int unsigned T_ARRD  = 32'd4;         // e08 sized decimal for the ARRAY bound
  parameter int unsigned T_ARRM  = B8 / 2;        // e09 divide     for the ARRAY bound
  parameter int unsigned T_ARRS  = A32 - 28;      // e10 subtract   for the ARRAY bound
endpackage

module m53 import r53::*; (input logic clk);
  logic [T_PLAIN-1:0] c01;
  logic [T_DEC  -1:0] c02;
  logic [T_UDEC -1:0] c03;
  logic [T_SDECL-1:0] c04;
  logic [T_REFD -1:0] c05;
  logic [T_HEX  -1:0] c06;
  logic [T_NMUL -1:0] c07;
  el_t  [T_ARRD -1:0] c08;
  el_t  [T_ARRM -1:0] c09;
  el_t  [T_ARRS -1:0] c10;
endmodule

module tb53;
  logic clk;
  m53 u (.clk(clk));
endmodule
