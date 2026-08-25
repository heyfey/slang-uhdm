// r10v87 arm va1 — A FORMAL WITH NO DEFAULT, overridden, colliding with a
// wildcard-imported package member.  Surelog's set holds the FORMAL NAME the
// instantiation overrode regardless of whether the formal had a default; the
// patch's predicate is `isOverriddenParam(om7)`, which returns FALSE when the
// declaration has no default syntax (EmitHelpers.h:1178).  If golden stamps
// the import copy here and we do not, this is a MISS (residue), not a
// regression.
package pn1;
  localparam int NA = 51;
  localparam int NB = 52;
endpackage

module nleaf #(
  parameter int NA,          // NO DEFAULT — must be overridden
  parameter int NC = 3
) (output logic [7:0] o);
  import pn1::*;
  assign o = NA[7:0] + NB[7:0] + NC[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  nleaf #(.NA(7))            u_a (.o(o1));
  nleaf #(.NA(7), .NC(9))    u_b (.o(o2));
endmodule
