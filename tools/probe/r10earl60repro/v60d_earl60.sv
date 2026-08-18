// r10earl60 arm D — the `!isImported` FENCE, i.e. the shape whose absence the
// 3-way census caught as AWAY-GOLDEN=293 on Earlgrey_0_1/default.
//
// A module WILDCARD-IMPORTS package `mid`; `mid`'s own localparams are
// initialised from a THIRD package `src`.  The module therefore emits
// MATERIALIZED IMPORT COPIES of mid's parameters whose initializer is a bare
// `src::name` reference -- and golden gives those copies the typespec of the
// package that DECLARES them (`mid`), NOT the one the value came from (`src`).
// Only a parameter DECLARED IN THE MODULE takes the source package's typespec.
package src;
  localparam int          SA = 8;
  localparam logic [11:0] SB = 12'h380;
endpackage

package mid;
  localparam int          MA = src::SA;      // package -> package
  localparam logic [11:0] MB = src::SB;
  localparam int          ML = 4;
endpackage

module s_imp_mid ();
  import mid::*;                             // materializes MA, MB, ML here
  localparam int own = src::SA;              // DECLARED here: takes src's ts
  logic [MA-1:0] d;
  logic [ML-1:0] e;
endmodule

module s_imp_both ();
  import mid::*;
  import src::*;
  localparam int own2 = src::SA;
endmodule

module a1 ();
  s_imp_mid  u0 ();
  s_imp_both u1 ();
endmodule
