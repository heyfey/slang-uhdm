// r10earl29 VERIFIER arm v5 — the GENERATE / GENVAR axis.  Campaign memory says
// an elaborated generate constant-assign FOLDS the genvar to its iteration value
// while written localparams keep their identifier; `idxDecompile` renders every
// NamedValue as its NAME, so a genvar (or a per-iteration localparam) inside a
// concatenation index is the cell where "ref_obj -> its name" could be wrong.
module v5_gen (
    input  logic [3:0] w,
    output logic [1:0] o,
    output logic [1:0] p
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      // genvar used as the index of an element-select element
      assign o[gi] = q.autoexecprogbuf[{1'b1, k[gi]}];
      // per-iteration localparam as a bare concat element
      localparam logic [1:0] LI = gi[1:0];
      assign p[gi] = q.autoexecprogbuf[{1'b1, LI}];
    end
  endgenerate
endmodule
