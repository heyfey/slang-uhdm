// r10earl45 VERIFIER probe 2 — the two shapes where `stamp45`'s
// vpiAssignmentPatternOp predicate can fire on something that is NOT a ROW.

package x45_pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sp_t;
  typedef struct        { int c; int d; }                 su_t;
endpackage

// X1 — a ONE-DIMENSIONAL unpacked array of PACKED STRUCTS.  Its operands are
//      STRUCT assignment patterns, so they ARE vpiAssignmentPatternOp and
//      arm 3's predicate accepts them — but they are FIELD LISTS, not rows of
//      a table.  Does golden size the first one?
module x45_flat_pstruct;
  import x45_pkg::*;
  localparam sp_t T [2] = '{'{a:8'h1,b:8'h2},'{a:8'h3,b:8'h4}};
endmodule

// X2 — the same with an UNPACKED struct element.
module x45_flat_ustruct;
  import x45_pkg::*;
  localparam su_t T [2] = '{'{c:1,d:2},'{c:3,d:4}};
endmodule

// X3 — a 2-D table nested INSIDE a struct pattern: at the array pattern
//      `wasInPattern` is TRUE, so the law refuses to stamp.  Does golden?
package x45_pkg2;
  typedef struct { int m [2][3]; } holder_t;
endpackage
module x45_in_struct;
  import x45_pkg2::*;
  localparam holder_t H = '{m: '{'{1,2,3},'{4,5,6}}};
endmodule

// X4 — a ONE-DIMENSIONAL unpacked array of packed VECTORS written as patterns
//      (the operand is a pattern over a PACKED type, not a row).
module x45_flat_pvec;
  localparam logic [3:0][7:0] T [2] = '{'{8'h1,8'h2,8'h3,8'h4},
                                        '{8'h5,8'h6,8'h7,8'h8}};
endmodule

// X5 — the control: a 2-D table of the same packed struct (a genuine table).
module x45_table_pstruct;
  import x45_pkg::*;
  localparam sp_t T [2][2] = '{'{'{a:8'h1,b:8'h2},'{a:8'h3,b:8'h4}},
                               '{'{a:8'h5,b:8'h6},'{a:8'h7,b:8'h8}}};
endmodule
