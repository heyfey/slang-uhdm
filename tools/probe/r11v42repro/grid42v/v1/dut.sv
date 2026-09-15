// v11u42 arm v1 — PACKAGE-PARAMETER VALUE KINDS in a trailing member-select index.
package pv1;
  localparam int unsigned LP    = 8;
  localparam logic [7:0]  B8    = 8'hA;        // based-literal init
  localparam int unsigned DER   = LP + 2;      // derived (non-literal) init
  localparam int          NEG   = -3;          // signed negative
  localparam int unsigned USCOR = 32'h0000_000C; // underscores in the literal
  parameter  int unsigned PP    = 4;
  typedef enum logic [3:0] { E0 = 4'd2, E1 = 4'd6 } e_t;
  localparam e_t          ENUMP = E1;          // enum-typed parameter
  localparam real         RP    = 2.0;         // NOT an integer
  localparam string       SP    = "ab";        // NOT an integer
  localparam int unsigned ARR [0:1] = '{3, 5}; // unpacked array parameter
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

module v1 (input logic [19:0] w20, output logic [63:0] o);
  pv1::s_t v;
  assign v = w20;
  assign o[0]  = v.m[pv1::LP-1];        // c01 control, plain int localparam
  assign o[1]  = v.m[pv1::B8-1];        // c02 based-literal init
  assign o[2]  = v.m[pv1::DER-1];       // c03 derived init
  assign o[3]  = v.m[pv1::NEG+5];       // c04 signed negative value
  assign o[4]  = v.m[pv1::USCOR-1];     // c05 underscored literal init
  assign o[5]  = v.m[pv1::ENUMP-1];     // c06 enum-typed parameter
  assign o[6]  = v.m[int'(pv1::RP)];    // c07 real parameter under a cast
  assign o[7]  = v.m[pv1::ARR[1]-1];    // c08 unpacked-array param element
  assign o[8]  = v.m[pv1::PP*pv1::LP-30];// c09 two pkg leaves, mult
  assign o[9]  = v.m[{2'b00,pv1::PP[1:0]}]; // c10 concat OF a pkg param bits
  assign o[10] = v.m[pv1::LP[2:0]];     // c11 part-select OF a pkg param
endmodule
