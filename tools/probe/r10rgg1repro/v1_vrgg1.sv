// v1 — QUALIFIED package enum const onto an interface member (the pkgEnumRhs
// LOCATED-fold law the new ifaceDotFresh arm now bypasses), vs unqualified.
package p_v1;
  typedef enum logic [1:0] { PK_OKAY = 2'b00, PK_ERR = 2'b11 } pk_e;
  typedef enum logic [3:0] { PK_H = 4'h6 } pkh_e;
endpackage

interface if_v1;
  logic [1:0] a, b, c, d;
  logic [3:0] e, f;
endinterface

module dut_v1 (if_v1 vif);
  import p_v1::*;
  typedef enum logic [1:0] { L_OKAY = 2'b00, L_ERR = 2'b10 } l_e;
  assign vif.a = p_v1::PK_OKAY;   // A1 QUALIFIED pkg enum const
  assign vif.b = PK_OKAY;         // A2 unqualified (import *)
  assign vif.c = L_OKAY;          // A3 module-local enum const
  assign vif.d = p_v1::PK_ERR;    // A4 QUALIFIED, nonzero value
  assign vif.e = p_v1::PK_H;      // A5 QUALIFIED, HEX member
  assign vif.f = PK_H;            // A6 unqualified, HEX member
endmodule

module v1_vrgg1;
  if_v1 vif();
  dut_v1 u (.vif(vif));
endmodule
