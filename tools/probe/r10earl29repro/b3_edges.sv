// r10earl29 GRID arm b3 — the EDGES of the element renderer, so that no cell of
// the shipped rule is a guess:
//   * a WILDCARD-IMPORTED package parameter element.  The whole-index case
//     reduces to its VALUE in our emitter today (`§ hierSelPkgParamFold`,
//     reducedImportedIdx); this arm measures whether golden reduces it INSIDE a
//     concatenation too, because carrying that behaviour over would otherwise be
//     an unmeasured guess.
//   * an INDEXED part select element (`k+:2`), a CAST element, `$bits`, a
//     cross-instance HIERARCHICAL reference element, and a replication whose
//     repeated part is a multi-element concat.
package pk3;
  parameter logic [1:0] PP = 2'd1;
endpackage
module sub3 (
    output logic [1:0] x
);
  assign x = 2'd0;
endmodule
module b3_edges (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6
);
  import pk3::*;
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  logic [1:0] hx;
  sub3 u (.x(hx));
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, PP}];            // wildcard-imported pkg param
    o2 = q.autoexecprogbuf[{1'b1, w[1+:2]}];       // indexed part select
    o3 = q.autoexecprogbuf[{1'b1, 2'(k)}];         // cast
    o4 = q.autoexecprogbuf[{1'b1, $signed(k)}];    // sys_func_call, NON-const arg
    // REFUTED CELL: `{1'b1, $bits(k)}` cannot be built at all — both elements are
    // constant, so slang folds the index to 33'h100000004 and rejects it -Windex-oob.
    // The CONSTANT-sys_func_call cell is covered instead by a5_three o6
    // (`{1'b1, $clog2(4), k}`), which escapes the fold because `k` is not constant.
    o5 = q.autoexecprogbuf[{1'b1, u.x}];           // cross-instance hier ref
    o6 = q.autoexecprogbuf[{1'b1, {2{1'b1, 1'b0}}}];// replication of a 2-elem concat
  end
endmodule
