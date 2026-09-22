// r11u86 arm b1 — LAW B's PIN, exercised on BOTH qualified spellings the
// producer routes through the same hand-on-less clone: `paPackage_scope`
// (CompileExpression.cpp:2723) and `paClass_type` (:2767).  A PACKAGE pattern,
// so § patternHomeIsAPackage81v lets the typespec law run and the spelling is
// the only variable.
package b1a;
  localparam BH = 16'h5;
endpackage
package b1b;
  import b1a::*;
  localparam LH = 16'h5;
  class c1;
    localparam CH = 16'h5;
  endclass
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e;
  } tb;
  localparam tb Y = '{bail: 8'hxA, a: LH, b: b1b::LH, c: BH, d: b1a::BH,
                      e: c1::CH};
endpackage
module b1_pin86 (output logic [23:0] o);
  localparam b1b::tb YR = b1b::Y;
  assign o = YR.a ^ b1b::Y.b;
endmodule
