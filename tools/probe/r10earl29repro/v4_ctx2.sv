// r10earl29 VERIFIER arm v4 — the CONTEXT cells a4 skipped: a MACRO-expanded
// index (rawText inside a macro body is a known trap in this emitter — see
// macroExpandedText, defined right beside the new code), a FUNCTION body, a TASK
// body, and a CROSS-INSTANCE hierarchical prefix in front of the member select
// (which reaches emitMixedHierPath with a hier root rather than a local var).
`define VIDX(a) {1'b1, a}
module v4_sub (
    input  logic [3:0] k,
    output logic       y
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q2;
  assign y = q2.autoexecprogbuf[0];
endmodule
module v4_ctx2 (
    input  logic       clk,
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  logic       sy;
  v4_sub u (.k(k), .y(sy));

  function automatic logic fx2(input logic [3:0] x);
    return q.autoexecprogbuf[{1'b1, x[0]}];      // inside a FUNCTION body
  endfunction
  task automatic tk(output logic y);
    y = q.autoexecprogbuf[{1'b1, k[0]}];         // inside a TASK body
  endtask

  assign o1 = q.autoexecprogbuf[`VIDX(k[0])];    // MACRO-expanded index
  assign o2 = fx2(w);
  always_comb tk(o3);
  assign o4 = u.q2.autoexecprogbuf[{1'b1, k[0]}];// CROSS-INSTANCE hier prefix
endmodule
