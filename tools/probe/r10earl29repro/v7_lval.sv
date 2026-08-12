// r10earl29 VERIFIER arm v7 — the INDIRECT name site.  `dotted` is not only the
// hier_path's VpiName: on the LVALUE path emitMixedHierPath passes it as the NAME
// PREFIX for the index's own sub-objects,
//     emitExpr(*sel.sel, bs, prefix + "." + dotted, netMap)
// so the patch changes the FULLNAME of every ref_obj / bit_select INSIDE a
// concatenation index in an lvalue select as a side effect.  cells.py does not
// track ref_obj, so no shipped-grid cell can see it.  This arm makes those inner
// objects exist (a bare ref, a bit select, a member ref) in an LVALUE select.
module v7_lval (
    input  logic       clk,
    input  logic [3:0] w,
    output logic       o1
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  t;
  st_t  t2;
  st_t  t3;
  req_t rq;
  logic [3:0] k;
  logic       kb;
  assign o1 = t.autoexecprogbuf[0];
  always_comb begin
    t.autoexecprogbuf[{1'b1, kb}]   = 1'b0;   // LVALUE, BARE REF element
  end
  always_comb begin
    t2.autoexecprogbuf[{1'b1, k[0]}] = 1'b0;  // LVALUE, BIT-SELECT element
  end
  // REFUTED CELL: `assign t3.autoexecprogbuf[{1'b1, kb}] = 1'b0;` — slang rejects
  // a non-constant concatenation index on a CONT-ASSIGN lvalue
  // ("reference to non-constant variable 'kb' is not allowed in a constant
  // expression"), so that context cannot be measured on this pair of tools.
  // Surelog accepts it; the golden-only reading is quoted in README.verifier.md.
endmodule
