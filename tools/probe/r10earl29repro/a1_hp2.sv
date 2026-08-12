// r10earl29 GRID arm a1 — HIER_PATH context (struct member packed array),
// 2-element concatenation index, the CANDIDATE in the **SECOND** position.
// This is the Earlgrey_0_1 shape:
//   cmd_valid_d = abstractauto_q.autoexecprogbuf[{1'b1, dmi_req_i.addr[3:0]}];
// One statement per candidate kind so each cell is keyed by its own LINE.
module a1_hp2 (
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
    o1  = q.autoexecprogbuf[{1'b1, 4'd3}];        // C2 constant
    o2  = q.autoexecprogbuf[{1'b1, k}];           // C2 simple local ref
    o3  = q.autoexecprogbuf[{1'b1, rq.addr}];     // C2 HIER ref (target shape)
    o4  = q.autoexecprogbuf[{1'b1, w[3:0]}];      // C2 part(range) select
    o5  = q.autoexecprogbuf[{1'b1, w[2]}];        // C2 bit select
    o6  = q.autoexecprogbuf[{1'b1, {1'b0, 1'b1}}];// C2 nested concat
    o7  = q.autoexecprogbuf[{1'b1, {2{1'b1}}}];   // C2 replication
    o8  = q.autoexecprogbuf[{1'b1, fx(k)}];       // C2 function call
    o9  = q.autoexecprogbuf[{1'b1, m[1][2]}];     // C2 multi-dim select
    o10 = q.autoexecprogbuf[{1'b1, rq.addr[3:0]}];// C2 HIER ref + range select
  end
endmodule
