// qd21.sv — PASS 21.  After § genConnIdxFoldConnOnly21 the top_earlgrey
// bisect advanced again, to ibex_prefetch_buffer.sv:89:59
//   for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rd_rev
//     assign rdata_outstanding_rev[i] = rdata_outstanding_q[NUM_REQS-1-i];
//   end
// inside a module that is ITSELF instantiated in a gen scope.  Golden keeps
// the two op=11 operations and folds ONLY the module localparam leaf to a
// `constant {ct=9 sz=32 dec=2}` carrying a ref_typespec (§ genCaLoopParamFold's
// law); we keep `ref_obj 'NUM_REQS'`.
//
// The question this file answers is whether the enclosing GEN SCOPE of the
// CHILD is the discriminator: same definition, instantiated plainly (A) and
// inside a gen scope (B).
module qd21_child (
    input  logic [3:0] q,
    output logic [1:0] r
);
  localparam int unsigned NUM_REQS = 2;
  for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rev
    assign r[i] = q[NUM_REQS-1-i];
  end
endmodule

module qd21 (
    input  logic [3:0] q,
    output logic [1:0] a,
    output logic [1:0] b
);
  qd21_child u_plain (.q(q), .r(a));      // A: plain child

  if (1) begin : gen_x
    qd21_child u_gen (.q(q), .r(b));      // B: child inside a gen scope
  end
endmodule
