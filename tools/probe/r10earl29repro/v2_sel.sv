// r10earl29 VERIFIER arm v2 — the SELECT-SHAPE product cells the shipped grid
// skipped.  `selBaseInfo` calls a chain "simple base" whenever it bottoms out at
// a NamedValue, IGNORING how many element-select levels sit under a RANGE select,
// and it counts levels only for element selects.  These are the cells where that
// simplification could be wrong.
module v2_sel (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  q;
  req_t rq;
  logic [3:0] k;
  logic [1:0][3:0] m;
  logic [1:0][1:0][3:0] m3;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, m[1][3:0]}];   // RANGE over an element-select base
    o2 = q.autoexecprogbuf[{1'b1, m3[1][0][2]}]; // THREE element-select levels
    o3 = q.autoexecprogbuf[{1'b1, m[k[0]]}];     // single level, NON-const index
    o4 = q.autoexecprogbuf[{1'b1, q.autoexecprogbuf[2]}]; // element select on a MEMBER
    o5 = q.autoexecprogbuf[{1'b1, w[k[0]+:2]}];  // indexed part select, non-const offset
  end
endmodule
