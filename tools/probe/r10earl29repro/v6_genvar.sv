// r10earl29 VERIFIER arm v6 — the genvar as a BARE concat element, isolated in its
// own arm because it is the cell most likely to be rejected by one of the two
// front ends (a rejection here must not cost the v5 readings).
module v6_genvar (
    output logic [1:0] o
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      assign o[gi] = q.autoexecprogbuf[{gi[0], k[0]}];
    end
  endgenerate
endmodule
