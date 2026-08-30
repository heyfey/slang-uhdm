// r10earl102 g1_form102 -- BOUND FORMS on a PACKAGE parameter's unpacked
// RANGE dimension, read back through a module's MATERIALIZED IMPORT copy
// (the head's own site: pinmux_pkg.sv:20 `parameter int MioStrapPos
// [0:NStraps-1]` reached through work@top_earlgrey.u_pinmux).
//
// Axis: what the bound EXPRESSION is.  A literal and a bare parameter
// reference are the two controls whose behaviour is already fixed by
// precedent (§ PackageEval / § defDimPkgParamFold); every arithmetic form is
// the law's own question.
package p1f102;
  parameter int NA = 2;
  parameter int NB = 4;
  parameter int PARR [0:1] = '{3, 1};
  typedef logic [7:0] w_t;

  parameter int F0 [0:NA-1]        = '{1, 0};                  // param-1  (THE HEAD)
  parameter int F1 [0:NA]          = '{1, 0, 2};               // bare param ref
  parameter int F2 [0:NA+1]        = '{1, 0, 2, 3};            // param+1
  parameter int F3 [0:$clog2(NB)]  = '{1, 0, 2};               // $clog2
  parameter int F4 [0:$bits(w_t)-1]= '{0,1,2,3,4,5,6,7};       // $bits - 1
  parameter int F5 [0:3]           = '{1, 0, 2, 3};            // literal
  parameter int F6 [0:NB-NA]       = '{1, 0, 2};               // two parameters
  parameter int F7 [NA-1:0]        = '{1, 0};                  // LEFT position
  parameter int F8 [NB-1:NB-2]     = '{1, 0};                  // BOTH bounds
  parameter int F9 [0:PARR[0]]     = '{1, 0, 2, 3};            // nested select
endpackage

module m1f102
  import p1f102::*;
(
  output int o
);
  assign o = F0[0] + F1[0] + F2[0] + F3[0] + F4[0] + F5[0] +
             F6[0] + F7[0] + F8[NB-1] + F9[0];
endmodule

module g1_form102 (output int o);
  m1f102 u (.o(o));
endmodule
