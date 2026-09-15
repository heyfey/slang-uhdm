// v11u38 adversarial arm 2 — a param default written as a bare NAME.
package ip2;
  parameter int A32  = 32;
  parameter     SUB  = A32 - 8 - 3 + 1;   // INT:22
  parameter     MUL  = A32 * 2;           // INT:64
  parameter     CMPV = (A32 > 8);         // BIN:1
  parameter     NEG  = 0 - 5;             // INT:-5
  parameter     ADDU = A32 + 8;           // UINT:40
  parameter     LVEC = 8'hA5;             // HEX
  parameter     DVEC = 6'd12;             // DEC
  parameter     OVEC = 9'o17;             // OCT
  parameter     HOP  = SUB;               // a hop
endpackage

module v2_m import ip2::*; #(
    parameter int unsigned P_PLAIN  = SUB,
    parameter bit [3:0]    P_TRUNC  = SUB,     // TRUNCATION: 22 -> 6
    parameter bit [1:0]    P_TRUNC2 = LVEC,    // A5 -> 1
    parameter logic [7:0]  P_HEX    = LVEC,
    parameter logic [5:0]  P_DEC    = DVEC,
    parameter logic [8:0]  P_OCT    = OVEC,
    parameter              P_CMP    = CMPV,
    parameter int          P_NEGT   = NEG,
    parameter int          P_ADDU   = ADDU,
    parameter int          P_HOP    = HOP,
    parameter int          P_QUAL   = ip2::SUB,
    parameter int          P_MUL    = MUL
) ();
  localparam L_SUB  = SUB;
  localparam int L_CMP = ip2::CMPV;
  localparam int L_LOC = P_PLAIN;      // a MODULE-local name
endmodule

interface v2_if import ip2::*; #(parameter int I_SUB = SUB) ();
endinterface

module v2_top ();
  v2_m u0 ();
  v2_m #(.P_PLAIN(7)) u1 ();           // the OVERRIDE face
  v2_if u_if ();
  localparam int T_SUB = ip2::SUB;
endmodule
