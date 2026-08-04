// r10earl3 x.sv — a REPLICATION nested in a CONCATENATION inside a GENERATE
// block's continuous assignment.  The def view of such a gen block is
// syntax-emitted (emitSyntaxExpr), and that emitter has a
// ConcatenationExpression case but NO MultipleConcatenationExpression case, so
// the replication operand vanishes from the def-view concat.
// Corpus: prim_fifo_sync.sv:110
//   assign full = (fifo_wptr == (fifo_rptr ^ {1'b1,{(PTR_WIDTH-1){1'b0}}}));
// — 13 Earlgrey AllModules def entries.
module xsub #(parameter int unsigned Depth = 4) (input logic [7:0] a,
                                                 output logic [7:0] o,
                                                 output logic       f);
  if (Depth == 0) begin : gen_pass
    assign o = a;
    assign f = 1'b0;
  end
  else begin : gen_norm
    localparam int unsigned PW = Depth + 1;
    // 1: replication INSIDE a concat, continuous assignment
    assign o = a ^ {1'b1, {(PW-1){1'b0}}};
    // 2: BARE replication (no enclosing concat), continuous assignment
    logic [7:0] r2;
    assign r2 = {(PW){1'b0}};
    // 3: replication inside a concat, PROCEDURAL assignment (control — this
    //    one already matches)
    logic [7:0] r3;
    always_comb begin
      r3 = {{(PW-1){1'b0}}, 1'b1};
    end
    assign f = |(r2 ^ r3);
  end
endmodule

module xtop (input logic [7:0] a, output logic [7:0] o, output logic f);
  xsub #(.Depth(4)) u(.a(a), .o(o), .f(f));
endmodule
