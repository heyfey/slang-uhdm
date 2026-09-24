// r10earl29 GRID arm a2 — HIER_PATH context, 2-element concatenation index,
// the CANDIDATE in the **FIRST** position (mirror of a1).  Tests hypothesis (d)
// "only the FIRST element ever renders" directly: if (d) held, the candidate
// would render here and the trailing constant would not.
module a2_hp1 (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6,
    output logic       o7,
    output logic       o8,
    output logic       o9,
    output logic       o10
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  q;
  req_t rq;
  logic [3:0] k;
  logic [1:0][3:0] m;
  function automatic logic [3:0] fx(input logic [3:0] x);
    return x;
  endfunction
  always_comb begin
    o1  = q.autoexecprogbuf[{4'd3, 1'b1}];        // C1 constant
    o2  = q.autoexecprogbuf[{k, 1'b1}];           // C1 simple local ref
    o3  = q.autoexecprogbuf[{rq.addr, 1'b1}];     // C1 HIER ref
    o4  = q.autoexecprogbuf[{w[3:0], 1'b1}];      // C1 part(range) select
    o5  = q.autoexecprogbuf[{w[2], 1'b1}];        // C1 bit select
    o6  = q.autoexecprogbuf[{{1'b0, 1'b1}, 1'b1}];// C1 nested concat
    o7  = q.autoexecprogbuf[{{2{1'b1}}, 1'b1}];   // C1 replication
    o8  = q.autoexecprogbuf[{fx(k), 1'b1}];       // C1 function call
    o9  = q.autoexecprogbuf[{m[1][2], 1'b1}];     // C1 multi-dim select
    o10 = q.autoexecprogbuf[{rq.addr[3:0], 1'b1}];// C1 HIER ref + range select
  end
endmodule
