// r10earl29 GRID arm a5 — THREE-element concatenations, so the COMMA policy is
// measurable independently of the element policy: with N elements golden emits
// N-1 separators, and which ones survive says whether an empty element still
// contributes its comma (the target cell shows `{1'b1,}` — comma PRESERVED).
// Also: a sys_func_call element, and a concat whose EVERY element is empty.
module a5_three (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  q;
  req_t rq;
  logic [3:0] k;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b0, 1'b1, 1'b1}];              // all constants
    o2 = q.autoexecprogbuf[{1'b0, rq.addr[1:0], 1'b1}];      // empty in MIDDLE
    o3 = q.autoexecprogbuf[{rq.addr[1:0], 1'b1, 1'b0}];      // empty FIRST
    o4 = q.autoexecprogbuf[{1'b0, 1'b1, rq.addr[1:0]}];      // empty LAST
    o5 = q.autoexecprogbuf[{rq.addr[1:0], rq.addr[1:0]}];    // EVERY elem empty
    o6 = q.autoexecprogbuf[{1'b1, $clog2(4), k}];            // sys_func_call
  end
endmodule
