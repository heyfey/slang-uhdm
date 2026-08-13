// r10earl41 VERIFIER probe — is § qualSelBaseNoWhitespace41 COMPLETE?
// F3 strips WHITESPACE from a base sliced out of the written source text.
// A COMMENT is not whitespace.  Golden's name is `q41::A` for all of these.
package q41;
  parameter logic [3:0][7:0] A = {8'h9, 8'ha, 8'hb, 8'hc};
endpackage
module v41v_comment #(parameter int DW = 8) (output logic [7:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    // k0 CONTROL — no whitespace, no comment.
    logic [7:0] c_k0;
    assign c_k0 = q41::A[g][DW-1:0];
    // k1 — a block comment AFTER the `::`.
    logic [7:0] c_k1;
    assign c_k1 = q41::/*x*/A[g][DW-1:0];
    // k2 — a block comment BEFORE the first selector.
    logic [7:0] c_k2;
    assign c_k2 = q41::A/*y*/[g][DW-1:0];
    // k3 — a line comment inside the qualified base.
    logic [7:0] c_k3;
    assign c_k3 = q41:: // z
                  A[g][DW-1:0];
  end
  assign o = gb[0].c_k0 ^ gb[0].c_k1 ^ gb[0].c_k2 ^ gb[0].c_k3;
endmodule
