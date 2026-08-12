// r10earl29 GRID arm a4 — SAME hier-ref-in-concat index, FIVE CONTEXTS.
// The rendering rule must be read per context, because this emitter's hier_path
// naming is already known to be context-dependent (lvalue vs rvalue, process vs
// cont-assign, def vs elab view).
//   c1  module-scope CONT-ASSIGN rvalue
//   c2  always_comb, UNNAMED block
//   c3  always_comb, NAMED block
//   c4  always_ff (sequential)
//   c5  cont-assign / process LVALUE (the select is the assignment TARGET)
module a4_ctx (
    input  logic       clk,
    input  logic [3:0] w,
    output logic       c1,
    output logic       c2,
    output logic       c3,
    output logic       c4
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  q;
  st_t  t;
  req_t rq;

  assign c1 = q.autoexecprogbuf[{1'b1, rq.addr}];

  always_comb begin
    c2 = q.autoexecprogbuf[{1'b1, rq.addr}];
  end

  always_comb begin : nb
    c3 = q.autoexecprogbuf[{1'b1, rq.addr}];
  end

  always_ff @(posedge clk) begin
    c4 <= q.autoexecprogbuf[{1'b1, rq.addr}];
  end

  always_comb begin
    t.autoexecprogbuf[{1'b1, rq.addr}] = 1'b0;   // LVALUE
  end
endmodule
