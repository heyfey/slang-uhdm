// r10v154 arm E — THE IMPORT-LISTING CLONE.
//
// A package enum with `-0`, leading zeros and a plain negative, reached through
// a module's wildcard import so the module listing carries a CLONE of the
// enum_typespec.  The clone takes the package/module spelling, never the
// `$unit` one: this arm scores IDENTICALLY (TO-GOLDEN=3 still-right=6) on the
// shipped first cut and on the fixed binary, so it pins that `unitEnum9` did
// not leak into the clone road.
package srcpkg;
  typedef enum bit [31:0] { CLONE_ZERO = -0, CLONE_LEAD = -007, CLONE_PLAIN = -3, CLONE_TAIL = 9 } clone_face_t;
endpackage
module midmod;
  import srcpkg::*;
  clone_face_t held;
  initial held = CLONE_PLAIN;
endmodule
module dut_clone; midmod u_mid (); endmodule
