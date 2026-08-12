// r10earl29 GRID arm a3 — PLAIN (non-hier) bit_select: the same concatenation
// indices applied to a FLAT packed vector, so there is no hier_path at all and
// the name under test is the bit_select's own VpiName/VpiFullName.
// If the rule lives in the hier_path builder only, these cells stay at source
// text on the golden side; if it lives in the SELECT name, they truncate too.
module a3_plain (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6,
    output logic       o7,
    output logic       o8
);
  typedef struct packed {logic [3:0] addr;} req_t;
  req_t rq;
  logic [31:0] pbuf;
  logic [3:0]  k;
  function automatic logic [3:0] fx(input logic [3:0] x);
    return x;
  endfunction
  always_comb begin
    o1 = pbuf[{1'b1, 4'd3}];         // constant
    o2 = pbuf[{1'b1, k}];            // simple local ref
    o3 = pbuf[{1'b1, rq.addr}];      // HIER ref
    o4 = pbuf[{1'b1, w[3:0]}];       // part(range) select
    o5 = pbuf[{1'b1, w[2]}];         // bit select
    o6 = pbuf[{1'b1, {1'b0, 1'b1}}]; // nested concat
    o7 = pbuf[{1'b1, {2{1'b1}}}];    // replication
    o8 = pbuf[{1'b1, fx(k)}];        // function call
  end
endmodule
