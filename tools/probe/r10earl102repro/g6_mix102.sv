// r10earl102 g6_mix102 -- THE DISTINGUISHER the g2 refutation demands.
//
// g2 measured that at the param_assign RHS operation's array_typespec golden
// FOLDS `[0:PN-1]` when the array is an imported PACKAGE parameter and KEEPS
// the op11 when the array is a module localparam / module parameter / an
// OVERRIDABLE module parameter / an interface parameter.  Two readings fit:
//   H_pkgsize  -- the SIZING identifier resolves to a PACKAGE parameter;
//   H_imported -- the ARRAY parameter itself is an imported package one.
// They differ on exactly one shape, and this arm is that shape: a MODULE's OWN
// unpacked-array localparam/parameter whose dimension is sized by an IMPORTED
// PACKAGE parameter.  A module-sized twin sits beside it as the control.
package p6m102;
  parameter int SN = 3;
  parameter int SPKG [0:SN-1] = '{2, 1, 0};
endpackage

module m6m102
  import p6m102::*;
(
  output int o
);
  localparam int LOCN = 2;
  localparam int MIX_PKGSIZE [0:SN-1]   = '{2, 1, 0};  // module array, PACKAGE size
  parameter  int MIXP_PKGSIZE [0:SN-1]  = '{2, 1, 0};  // module PARAM, PACKAGE size
  localparam int MIX_MODSIZE [0:LOCN-1] = '{1, 0};     // module array, MODULE size (control)
  assign o = SPKG[0] + MIX_PKGSIZE[0] + MIXP_PKGSIZE[0] + MIX_MODSIZE[0];
endmodule

module g6_mix102 (output int o);
  m6m102 u (.o(o));
endmodule
