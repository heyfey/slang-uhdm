// r10earl45 VERIFIER probe 3 — the SCOPE of the `!wasInPattern` misclassification.
// `inAssignPattern` is set ONLY by ExprEmit's SimpleAssignmentPattern case
// (14469) and two ParamEmit sites.  StructuredAssignmentPattern (14736) and
// ReplicatedAssignmentPattern (14695) do NOT set it, so an unpacked-array
// pattern nested under either one reads `wasInPattern == false` and is
// mistaken for the OUTERMOST pattern by § elabPatternFirstRowElemSize45.

package y45_pkg;
  typedef struct { int m [2][3]; }        h1_t;   // array under a STRUCT key
  typedef struct { int p [2][2][3]; }     h2_t;   // deeper, same nesting
endpackage

// Y1 — array table under a STRUCT pattern key (the minimal case).
module y45_struct_key;
  import y45_pkg::*;
  localparam h1_t H = '{m: '{'{1,2,3},'{4,5,6}}};
endmodule

// Y2 — three unpacked levels under a STRUCT pattern key.
module y45_struct_key3;
  import y45_pkg::*;
  localparam h2_t H = '{p: '{'{'{1,2,3},'{4,5,6}},'{'{7,8,9},'{10,11,12}}}};
endmodule

// Y3 — a table under a REPLICATION.  The replicated element is itself a
//      pattern-of-patterns, so the inner op is a 2-D table whose parent op is
//      a vpiMultiAssignmentPatternOp / concat, not a SimpleAssignmentPattern.
module y45_repl_table;
  localparam int T [2][2][3] = '{2{'{'{1,2,3},'{4,5,6}}}};
endmodule

// Y4 — the CONTROL: the identical table with no struct/replication above it.
module y45_plain;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule
