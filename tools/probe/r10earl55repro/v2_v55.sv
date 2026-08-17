// v55 adversarial arm 2 — TYPE VARIANTS at width 1, and the width ladder
// 1 / 2 / 32 / 64 as controls.  The law keys on
// `canonicalType.kind == PackedArrayType && isIntegral() && getBitWidth()==1`,
// so every neighbouring KIND that can also be one bit wide is here: a
// typedef'd vector, a typedef of a typedef, an enum with a 1-bit base, a
// 1-bit packed struct, a 1-bit packed union, `bit signed`, `[1:1]`, and a
// scalar.  Widths 2/32/64 must be BYTE-UNCHANGED by the patch.
// MEASURED (both views, both binaries): TO-GOLDEN 7 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  A typedef'd [0:0], a typedef OF a typedef, a `signed`
// typedef, `bit signed [0:0]`, `logic unsigned [0:0]` and a NON-zero-based
// [1:1] all reach the arm and all land on golden — and golden's int_typespec is
// UNSIGNED even for the signed declarations, which matters because
// int_typespec::Compare DOES read VpiSigned (UHDM int_typespec.cpp:106).
// The width ladder 2/32/64 (and signed 64) is BYTE-UNCHANGED: golden wants
// int_typespec there too (unused parameter = a4's c0 column) so those four are
// R1, not regressions.  A 1-bit packed STRUCT and a 1-bit packed UNION are
// PackedStruct/PackedUnion, never PackedArrayType: they never reach the arm and
// we emit NO typespec where golden emits int_typespec — a residue the pass did
// not name (V2).
package pv2_55;
  typedef logic [0:0]  t1_55;
  typedef t1_55        t2_55;
  typedef logic signed [0:0] ts_55;
  typedef enum logic [0:0] { E0, E1 } en_55;
  typedef struct packed { logic a; } st_55;
  typedef union packed { logic a; bit b; } un_55;
endpackage

module v2_v55(input logic ext);
  p0_v55 u_p0 (.o(), .ext(ext));
  p1_v55 u_p1 (.o(), .ext(ext));
  p2_v55 u_p2 (.o(), .ext(ext));
  p3_v55 u_p3 (.o(), .ext(ext));
endmodule

// typedef'd single-bit vectors: does a TypeAlias still reach the arm?
module p0_v55 (output logic o, input logic ext);
  localparam pv2_55::t1_55 TA = {1{1'b1}};
  localparam pv2_55::t2_55 TB = {1{1'b1}};
  localparam pv2_55::ts_55 TC = {1{1'b1}};
  assign o = ext;
endmodule

// enum / struct / union with a ONE BIT base — NOT PackedArrayType
module p1_v55 (output logic o, input logic ext);
  localparam pv2_55::en_55 EA = pv2_55::en_55'({1{1'b1}});
  localparam pv2_55::st_55 SA = {1{1'b1}};
  localparam pv2_55::un_55 UA = {1{1'b1}};
  assign o = ext;
endmodule

// signedness and two-state at width 1, plus [1:1]
module p2_v55 (output logic o, input logic ext);
  localparam bit signed [0:0]   VA = {1{1'b1}};
  localparam logic unsigned [0:0] VB = {1{1'b1}};
  localparam logic [1:1]        VC = {1{1'b1}};
  localparam bit                VD = {1{1'b1}};
  assign o = ext;
endmodule

// THE WIDTH LADDER — 1 / 2 / 32 / 64.  Only the width-1 cell may move.
module p3_v55 (output logic o, input logic ext);
  localparam logic [0:0]  W1  = {1{1'b1}};
  localparam logic [1:0]  W2  = {2{1'b1}};
  localparam logic [31:0] W32 = {32{1'b1}};
  localparam logic [63:0] W64 = {64{1'b1}};
  localparam logic signed [63:0] W64S = {64{1'b1}};
  assign o = ext;
endmodule
