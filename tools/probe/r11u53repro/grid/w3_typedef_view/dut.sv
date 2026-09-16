// r11u53 — the W3 CELL ON ITS OWN ARM.  FOLDMAP ROAD A's grid reports one
// VIEW-DEPENDENT cell that is NOT the type-parameter cell: a MODULE-LOCAL
// typedef (`typedef pk::req_t loc_t`) whose $bits golden KEEPS in the
// definition listing and FOLDS in the elaborated one.  A module-local typedef
// IS in `component->getDataType` (Surelog CompileHelper.cpp:636), so
// `getTypespec` resolves it and only `m_elabMode` can separate the views —
// the opposite of the type-parameter cell, where `getTypespec` returns null in
// BOTH views.  This arm asks whether the W3 behaviour depends on WHAT the
// local typedef aliases (a package struct, a package scalar, a built-in, or an
// inline struct), so the cell can be written with a known gate or recorded.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  typedef logic [7:0] byte_t;                                               // 8
endpackage
module dut (output logic o);
  typedef pk::req_t                                     l_struct_t;  // alias pkg struct
  typedef pk::byte_t                                    l_scalar_t;  // alias pkg scalar
  typedef logic [9:0]                                   l_builtin_t; // alias built-in
  typedef struct packed { logic [3:0] x; logic [1:0] y; } l_inline_t;// inline struct (6)
  localparam int V1 = $bits(l_struct_t);
  localparam int V2 = $bits(l_scalar_t);
  localparam int V3 = $bits(l_builtin_t);
  localparam int V4 = $bits(l_inline_t);
  localparam int V5 = $bits(pk::req_t);      // CONTROL package-qualified
  assign o = ^{V1[0], V2[0], V3[0], V4[0], V5[0]};
endmodule
