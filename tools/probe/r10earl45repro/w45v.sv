// r10earl45 VERIFIER probe — boundaries of § elabPatternFirstRowElemSize45
// that no cell in a1_earl45 / v45_order / v45_expr reaches.

// V1 — the FIRST ROW written as a REPLICATION.  Arm 3's predicate demands the
//      stamped operand BE a vpiAssignmentPatternOp; a replication row is a
//      vpiMultiAssignmentPatternOp, so we stamp NOTHING here.  Does golden?
module w45_repl_row0;
  localparam int T [2][3] = '{'{3{1}}, '{4,5,6}};
endmodule

// V2 — the LAST row a replication, DESCENDING outer: after the reverse the
//      replication lands at front() and the pattern row at back().
module w45_repl_desc;
  localparam int T [1:0][2:0] = '{'{1,2,3}, '{3{7}}};
endmodule

// V3 — element type NOT integral (real).  `leaf->isIntegral()` is false so we
//      stamp nothing.  Does golden stamp a width here?
module w45_real;
  localparam real T [2][3] = '{'{1.0,2.0,3.0},'{4.0,5.0,6.0}};
endmodule

// V4 — ONE row, DESCENDING outer.  front() == back(); the reorder gate needs
//      size>1 so no reverse fires, but the shape is the pair of m45_one.
module w45_one_desc;
  localparam int T [0:0][2:0] = '{'{1,2,3}};
endmodule

// V5 — a ONE-element 1-D unpacked array whose single operand is an
//      EXPRESSION.  THE ENTRY-GATE WIDENING (`operands->size() > 1 ||
//      nestedOpsPre9`, was `... && !isUnpackedArr`) makes this shape enter the
//      block for the FIRST TIME.  Nothing may move.
module w45_one_expr;
  localparam int T [1] = '{1344/64};
endmodule

// V6 — a ONE-element 1-D unpacked array of a CONCAT (same entry-gate story,
//      different operand op type).
module w45_one_concat;
  localparam logic [7:0] T [1] = '{{4'h1,4'h2}};
endmodule

// V7 — the table inside an INTERFACE rather than a module.
interface w45_if;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
endinterface
module w45_if_top;
  w45_if u_if ();
endmodule

// V8 — a table whose FIRST row is '{default:N} and whose second is explicit.
module w45_default_row0;
  localparam int T [2][3] = '{'{default:9}, '{4,5,6}};
endmodule

// V9 — a module PARAMETER overridden at the instantiation site.
module w45_povr_inner #(parameter int T [2][3] = '{'{1,2,3},'{4,5,6}}) ();
endmodule
module w45_povr_top;
  w45_povr_inner #(.T('{'{7,8,9},'{10,11,12}})) u_o ();
endmodule

// V10 — element type is a 2-state packed enum (integral, 2 bits).
package w45_epkg;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
endpackage
module w45_enum;
  import w45_epkg::*;
  localparam e_t T [2][2] = '{'{E0,E1},'{E1,E2}};
endmodule

// V11 — THREE unpacked dimensions with a PACKED element: the leaf strip must
//       stop at the packed vector (`logic [3:0][7:0]` -> 32), not at 8.
module w45_three_packedleaf;
  localparam logic [3:0][7:0] T [2][2] = '{'{'{8'h1,8'h2,8'h3,8'h4},
                                            '{8'h5,8'h6,8'h7,8'h8}},
                                          '{'{8'h9,8'ha,8'hb,8'hc},
                                            '{8'hd,8'he,8'hf,8'h0}}};
endmodule
