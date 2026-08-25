// r10v90 v3 — MORE DECLARED TYPES AND MORE PRODUCER CHAINS than g2/g4 carry.
// `paramDeclSigned90` is a transcription of `valueRange`'s three-kind switch
// onto slang's CANONICAL type; every canonical shape it can meet is tried.
package pv90;
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  localparam logic signed [7:0] PL = 4;
endpackage

typedef int          int_t90;          // typedef of a PREDEFINED signed int
typedef int unsigned uint_t90;
typedef bit signed [3:0] bs_t90;
typedef logic signed [1:0][3:0] l2d_t90;  // 2-D packed, signed
typedef enum int { EA90 = 4 } en_t90;     // ENUM with a signed int base
typedef struct packed { logic [3:0] f; } st_t90;

module snk4_90 (input logic [3:0] a_i);
endmodule

module v3_types90;
  import pv90::*;
  localparam int_t90            T01 = 4;   // typedef -> int          (signed)
  localparam uint_t90           T02 = 4;   // typedef -> int unsigned
  localparam bs_t90             T03 = 4;   // typedef -> bit signed [3:0]
  localparam l2d_t90            T04 = 4;   // 2-D PACKED signed
  localparam logic signed [1:0][3:0] T05 = 4;   // 2-D packed signed, written
  localparam logic [1:0][3:0]   T06 = 4;   // 2-D packed UNSIGNED
  localparam reg signed [3:0]   T07 = 4;   // `reg signed`
  localparam en_t90             T08 = EA90; // an ENUM value
  localparam time               T09 = 4;   // `time` (unsigned 64)
  localparam bit                T10 = 1;   // a 1-bit `bit` (SCALAR, unsigned)
  localparam logic signed       T11 = 1;   // a SIGNED scalar logic
  localparam signed [3:0]       T12 = 4;   // IMPLICIT signed
  localparam [3:0]              T13 = 4;   // IMPLICIT unsigned
  localparam int                T14 = PS;      // bare ref to an IMPORTED pkg param
  localparam int unsigned       T15 = PS;      // unsigned decl <- imported signed
  localparam int                T16 = pv90::PU;  // signed decl <- QUALIFIED unsigned
  localparam int unsigned       T17 = pv90::PL;  // unsigned decl <- QUALIFIED logic signed
  localparam int                T18 = T14;      // TWO-deep bare chain (T14 <- PS)
  localparam int                T19 = T18;      // THREE-deep bare chain
  localparam int unsigned       T20 = T19;      // unsigned decl at the end of a signed chain
  localparam int                T21 = 3 + 1;    // EXPRESSION initializer
  localparam int                T22 = int'(4);  // written CAST initializer
  localparam int                T23 = (PS);     // PARENTHESISED bare ref
  logic [31:0] sig;

  for (genvar g = 0; g < 1; g++) begin : gs
    snk4_90 c01 (.a_i(sig[g*4 +: T01]));
    snk4_90 c02 (.a_i(sig[g*4 +: T02]));
    snk4_90 c03 (.a_i(sig[g*4 +: T03]));
    snk4_90 c04 (.a_i(sig[g*4 +: T04]));
    snk4_90 c05 (.a_i(sig[g*4 +: T05]));
    snk4_90 c06 (.a_i(sig[g*4 +: T06]));
    snk4_90 c07 (.a_i(sig[g*4 +: T07]));
    snk4_90 c08 (.a_i(sig[g*4 +: T08]));
    snk4_90 c09 (.a_i(sig[g*4 +: T09]));
    snk4_90 c11 (.a_i(sig[g*4 +: T11 + 3]));
    snk4_90 c12 (.a_i(sig[g*4 +: T12]));
    snk4_90 c13 (.a_i(sig[g*4 +: T13]));
    snk4_90 c14 (.a_i(sig[g*4 +: T14]));
    snk4_90 c15 (.a_i(sig[g*4 +: T15]));
    snk4_90 c16 (.a_i(sig[g*4 +: T16]));
    snk4_90 c17 (.a_i(sig[g*4 +: T17]));
    snk4_90 c18 (.a_i(sig[g*4 +: T18]));
    snk4_90 c19 (.a_i(sig[g*4 +: T19]));
    snk4_90 c20 (.a_i(sig[g*4 +: T20]));
    snk4_90 c21 (.a_i(sig[g*4 +: T21]));
    snk4_90 c22 (.a_i(sig[g*4 +: T22]));
    snk4_90 c23 (.a_i(sig[g*4 +: T23]));
    // the same signed-int width read through a WRITTEN CAST and through
    // parentheses in the SELECT itself (not in the declaration).
    snk4_90 c24 (.a_i(sig[g*4 +: int'(T01)]));
    snk4_90 c25 (.a_i(sig[g*4 +: (T01)]));
  end
endmodule
