// v4 (VERIFIER) — the SCOPE axis: `paramCaFoldRead` only walks `body->members()`
// for ContinuousAssign, so a cont-assign nested in a GENERATE block is invisible
// to it.  Also the net-decl-assign form, an INTERFACE body, and a cont-assign
// inside an always-free nested generate-if.  H0 is the flat control.
interface v4_if #(
  parameter logic [31:0] IF1 = 32'h1,   // operand0 of an INTERFACE cont-assign
  parameter logic [31:0] IF2 = 32'h2    // never read
) (input logic [31:0] n);
  logic [31:0] oi;
  assign oi = IF1 | n;
endinterface

module v4_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] H0 = 32'h0,   // flat cont-assign, operand0 (control)
  parameter logic [W-1:0] H1 = 32'h1,   // operand0 inside a FOR-generate
  parameter logic [W-1:0] H2 = 32'h2,   // operand0 of a NET-DECL-ASSIGN
  parameter logic [W-1:0] H3 = 32'h3,   // operand0 inside an IF-generate
  parameter logic [W-1:0] H4 = 32'h4    // never read (control)
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o0, o1, o3
);
  assign o0 = H0 | n;
  wire [W-1:0] w2 = H2 | n;
  for (genvar k = 0; k < 1; k++) begin : gen_h
    assign o1 = H1 | n;
  end
  if (W > 0) begin : gen_i
    assign o3 = H3 | n;
  end
endmodule
