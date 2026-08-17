// r10earl50 VERIFIER arm w2 — GENERATE corners the pass's `condA/condB/condC`
// list does NOT name.  A CASE-GENERATE's ITEM LABEL is a constant expression
// Surelog evaluates at elaboration exactly like the case condition, but only
// the condition is marked `isCond`; every item label falls in the dropped BODY.
// Pristine answered BARE for all of these (select anywhere).
module w2_v50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] R1 = 'h1,  // select in a CASE-GENERATE ITEM LABEL
  parameter logic [W-1:0] R2 = 'h1,  // select in a CASE-GENERATE CONDITION   (control)
  parameter logic [W-1:0] R3 = 'h1,  // select in a for-generate STOP expr    (control)
  parameter logic [W-1:0] R4 = 'h1,  // select in a CA two gen levels deep
  parameter logic [W-1:0] R5 = 'h1,  // select in a gen block LOCALPARAM initializer
  parameter logic [W-1:0] R6 = 'h1,  // select in a TAKEN else-branch body CA
  parameter logic [W-1:0] R7 = 'h1,  // select in a for-generate INITIAL expr  (control)
  parameter logic [W-1:0] R8 = 'h1   // select in a GENERATE-REGION cont-assign (no gen block)
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o4, o6, o8
);
  // R1/R2 — a case-generate: condition is R2[1:0], one ITEM LABEL is R1[1:0]
  case (R2[1:0])
    R1[1:0]: begin : gen_r1a  wire [W-1:0] t1; assign t1 = n; end
    default: begin : gen_r1b  wire [W-1:0] t2; assign t2 = n; end
  endcase
  // R3 — a for-generate STOP expression
  for (genvar k = 0; k < R3[0]; k++) begin : gen_r3
    wire [W-1:0] t3; assign t3 = n;
  end
  // R7 — a for-generate INITIAL expression
  for (genvar k = R7[0]; k < 1; k++) begin : gen_r7
    wire [W-1:0] t7; assign t7 = n;
  end
  // R4 — a cont-assign TWO instantiated generate levels deep
  if (W > 0) begin : gen_r4a
    if (W > 1) begin : gen_r4b
      assign o4 = R4[0] | n[0];
    end
  end
  // R5 — a LOCALPARAM inside a generate block, initialised by a select
  if (W > 0) begin : gen_r5
    localparam logic [W-1:0] R5D = {24'b0, R5[7:0]};
    wire [W-1:0] t5; assign t5 = R5D;
  end
  // R6 — the TAKEN else branch of an if-generate
  if (W > 99) begin : gen_r6a
    wire [W-1:0] t6; assign t6 = n;
  end else begin : gen_r6b
    assign o6 = R6[0] | n[0];
  end
  // R8 — a cont-assign inside a bare generate REGION (no generate block at all)
  generate
    assign o8 = R8[0] | n[0];
  endgenerate
endmodule
