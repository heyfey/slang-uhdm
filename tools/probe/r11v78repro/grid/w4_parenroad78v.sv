// r11v78 VERIFIER arm w4 — THE ROADS § caSubstLeafCtSeesParens78 REACHES THAT
// THE PASS'S CENSUS DID NOT SCAN.  `dimRedCtExpr79` is not only the pattern
// operand's encoding classifier: `pkgSubstIntEnc50` (TypeEmit.cpp:700) and
// `caSubstLeafCt56` -> the cont_assign substitution (ModuleEmit.cpp:27823)
// both read it.  `basedLitOrigin50`, the abstention § pkgSubstEncBasedLit-
// Abstain50v landed to keep the package road off based literals, is STILL
// paren-blind, so a PARENTHESISED sized based literal now slips past it and
// reaches the table.  This arm is r11v50's `b3_dbase50` shape written with
// parentheses, beside its unparenthesised controls.
package r78;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } el_t;
  parameter int unsigned A32 = 32;

  parameter int unsigned P_PLAIN = 40;            // control: unsized literal
  parameter int unsigned P_DEC   = 32'd40;        // control: bare sized decimal
  parameter int unsigned P_PDEC  = (32'd40);      // THE FACE: parenthesised
  parameter int unsigned P_PPDEC = ((32'd40));    // doubly parenthesised
  parameter int unsigned P_PHEX  = (32'h28);      // parenthesised HEX
  parameter int unsigned P_PSDEC = (32'sd40);     // parenthesised SIGNED decimal
  parameter int unsigned P_REFP  = P_PDEC;        // a NAME to a parenthesised one
  parameter int unsigned P_PARM  = (32'd32) + 8;  // an ARM over one
  parameter int unsigned P_NMUL  = A32 * 2;       // control: the arm that moves
endpackage

module m78 import r78::*; (input logic clk);
  logic [P_PLAIN-1:0] c01;
  logic [P_DEC  -1:0] c02;
  logic [P_PDEC -1:0] c03;
  logic [P_PPDEC-1:0] c04;
  logic [P_PHEX -1:0] c05;
  logic [P_PSDEC-1:0] c06;
  logic [P_REFP -1:0] c07;
  logic [P_PARM -1:0] c08;
  logic [P_NMUL -1:0] c09;
endmodule

// The cont_assign substitution road: a struct parameter read through a
// generate scope, whose SETTERS are parenthesised based literals.
package q78;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] f0; logic [31:0] f1; logic [31:0] f2; logic [31:0] f3;
    logic [31:0] f4; logic [31:0] f5;
  } q78_t;
  localparam q78_t Q = '{f0: (32'd40), f1: 32'd40, f2: (32'h28),
                         f3: (32'sd40), f4: ((32'd40)), f5: K + 1};
endpackage

module w4_parenroad78v import q78::*; #(parameter q78_t CQ = q78::Q)
                                      (output logic [31:0] y0,
                                       output logic [31:0] y1,
                                       output logic [31:0] y2,
                                       output logic [31:0] y3,
                                       output logic [31:0] y4,
                                       output logic [31:0] y5,
                                       input logic clk);
  assign y0 = CQ.f0;
  assign y1 = CQ.f1;
  assign y2 = CQ.f2;
  assign y3 = CQ.f3;
  assign y4 = CQ.f4;
  assign y5 = CQ.f5;
  m78 u (.clk(clk));
endmodule
