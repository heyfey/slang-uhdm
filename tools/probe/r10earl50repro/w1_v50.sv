// r10earl50 VERIFIER arm w1 — INSTANCE ARRAYS and instance overrides in every
// scope.  § selectReadNeedsReduce50 drops `HierarchyInstantiation` from the
// syntax rule and hands instance overrides / port connections to
// paramCaFoldRead's new instance arm, which matches `SymbolKind::Instance`
// ONLY.  An instance ARRAY is `SymbolKind::InstanceArray` and is skipped by
// that arm, so the pass predicts LOCATED for Q1/Q2 where the pristine
// select-anywhere rule predicted BARE.  Golden decides.
module w1_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, output logic y);
  assign y = (^S) & p;
endmodule

module w1_v50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] Q1 = 'h0,  // select in an INSTANCE ARRAY param override
  parameter logic [W-1:0] Q2 = 'h0,  // select in an INSTANCE ARRAY port connection
  parameter logic [W-1:0] Q3 = 'h0,  // select in a SINGLE instance override  (= h1.HE)
  parameter logic [W-1:0] Q4 = 'h0,  // select in an instance override inside a TAKEN gen block
  parameter logic [W-1:0] Q5 = 'h0,  // select in an instance override inside a FOR-generate
  parameter logic [W-1:0] Q6 = 'h0,  // select in an instance override inside an UNTAKEN gen block
  parameter logic [W-1:0] Q7 = 'h0   // select in an instance ARRAY override inside a gen block
) (
  input  logic c,
  output logic [1:0] oa1, oa2, oa7,
  output logic o3, o4, o5
);
  // Q1 — instance ARRAY, parameter override carries the select
  w1_sub #(.S({24'b0, Q1[7:0]})) u_q1 [1:0] (.p(c), .y(oa1));
  // Q2 — instance ARRAY, PORT CONNECTION carries the select
  w1_sub #(.S(32'h0))            u_q2 [1:0] (.p(Q2[0]), .y(oa2));
  // Q3 — the single-instance control: this one the pass models
  w1_sub #(.S({24'b0, Q3[7:0]})) u_q3 (.p(c), .y(o3));
  // Q4 — single instance, override, inside a TAKEN generate block
  if (W > 0) begin : gen_q4
    w1_sub #(.S({24'b0, Q4[7:0]})) u (.p(c), .y(o4));
  end
  // Q5 — single instance, override, inside a for-generate
  for (genvar k = 0; k < 1; k++) begin : gen_q5
    w1_sub #(.S({24'b0, Q5[7:0]})) u (.p(c), .y(o5));
  end
  // Q6 — instance override inside an UNTAKEN generate block
  if (W > 99) begin : gen_q6
    w1_sub #(.S({24'b0, Q6[7:0]})) u (.p(c), .y());
  end
  // Q7 — instance ARRAY override inside a taken generate block
  if (W > 0) begin : gen_q7
    w1_sub #(.S({24'b0, Q7[7:0]})) u [1:0] (.p(c), .y(oa7));
  end
endmodule
