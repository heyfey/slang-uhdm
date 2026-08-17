// v55 adversarial arm 7 — THE MOST DANGEROUS REMAINING SHAPE.  The gate is
// `canonicalType.kind == PackedArrayType && isIntegral() && getBitWidth() == 1`,
// and a PACKED ARRAY whose ELEMENT is a 1-bit packed STRUCT or a 1-bit ENUM is
// ALSO a PackedArrayType, IS integral, and IS one bit wide — so the width-1 arm
// FIRES on it.  If golden hands those the element's named typespec instead of a
// loc-less int_typespec, this pass is an AWAY-GOLDEN on legal SV.  OpenTitan is
// full of `struct packed`-element vectors, so this is not a synthetic worry.
// MEASURED (both views, both binaries): TO-GOLDEN 3 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  The arm DOES fire on a packed array of a 1-bit packed
// struct, of a 1-bit enum and of a 1-bit packed union, and GOLDEN AGREES in
// all three: loc-less int_typespec UINT:1, no ranges, unsigned.  The width-2
// siblings are byte-unchanged and remain R1.  This was the pass's largest
// open AWAY-GOLDEN risk and it is closed by measurement.
package pv7_55;
  typedef struct packed { logic a; }      s1_55;
  typedef enum   logic [0:0] { Z0, Z1 }   e1_55;
  typedef union  packed { logic a; bit b; } u1_55;
endpackage

module v7_v55(input logic ext);
  t0_v55 u_t0 (.o(), .ext(ext));
  t1_v55 u_t1 (.o(), .ext(ext));
endmodule

// packed ARRAYS of one-bit composites, width 1 overall
module t0_v55 (output logic o, input logic ext);
  localparam pv7_55::s1_55 [0:0] AS = {1{1'b1}};
  localparam pv7_55::e1_55 [0:0] AE = {1{1'b1}};
  localparam pv7_55::u1_55 [0:0] AU = {1{1'b1}};
  assign o = ext;
endmodule

// the same shapes at width 2, as the control that must not move
module t1_v55 (output logic o, input logic ext);
  localparam pv7_55::s1_55 [1:0] BS = {2{1'b1}};
  localparam pv7_55::e1_55 [1:0] BE = {2{1'b1}};
  assign o = ext;
endmodule
