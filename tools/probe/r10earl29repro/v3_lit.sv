// r10earl29 VERIFIER arm v3 — the CONSTANT-SPELLING cells.  `idxDecompile` copies
// an IntegerLiteral's RAW SOURCE TEXT while claiming golden renders "its own
// spelling"; the two coincide only if Surelog's decompiler re-prints the source
// verbatim.  Uppercase bases/digits, underscores and unbased-unsized literals are
// where a re-printer normally normalises.
module v3_lit (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, 4'HA, k[0]}];  // UPPERCASE base and hex digit
    o2 = q.autoexecprogbuf[{1'b1, 4'd1_0, k[0]}];// UNDERSCORE inside the digits
    o3 = q.autoexecprogbuf[{1'b1, '0, k[0]}];    // unbased-unsized
    o4 = q.autoexecprogbuf[{1'b1, 2'sd1, k[0]}]; // SIGNED base
    o5 = q.autoexecprogbuf[{1'b1, 4'b10_10, k[0]}]; // binary with an underscore
  end
endmodule
