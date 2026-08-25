// r10v87 arm va2 — DEFPARAM.  Surelog applies defparams with
// `parent->setValue(name, value, ...)` (DesignElaboration.cpp:841-849) and
// NEVER calls setOverridenParam, so `m_overridenParams` stays empty and golden
// leaves BOTH the formal's row and the materialized import copy UNSTAMPED.
// Our `isOverriddenParam` is a SPAN test: slang binds the defparam expression
// as the parameter's initializer, whose syntax lies outside the declaration
// default, so it answers TRUE.  Pre-pass-87 that only mis-stamped the formal;
// the pass extends the same answer to the import copy.
package pd2;
  localparam int DA = 61;
  localparam int DB = 62;
endpackage

module dleaf #(parameter int DA = 1, parameter int DC = 3) (output logic [7:0] o);
  import pd2::*;
  assign o = DA[7:0] + DB[7:0] + DC[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  dleaf u_dp  (.o(o1));
  dleaf u_pl  (.o(o2));   // control: nothing overrides this one
  defparam u_dp.DA = 7;
endmodule
