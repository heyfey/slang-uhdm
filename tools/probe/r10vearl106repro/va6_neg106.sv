// r10v106 va6_neg106 — NEGATIVE and X/Z values, signed spellings, and the
// UINT:-1 / UINT:18446744073709551615 identity the patch's `stoll`/`stoull`
// split relies on.  Plus the non-cast gen-scope Rhs shapes that must NOT move
// (they belong to other landed laws).  MEASUREMENT ONLY.
package pv6_106;
  parameter int unsigned P8  = 8;
  parameter int unsigned P64 = 64;
  parameter int          S8  = 8;
endpackage

module va6_neg106 (output logic o);
  logic [7:0]  q1, q2, q3, q4, q5, q6;
  logic [63:0] q7, q8;
  logic [7:0]  r1, r2, r3, r4, r5, r6, r7, r8;

  // negative operands, cast width from a LITERAL vs a PARAMETER
  if (1) begin : y_negl  assign q1 = 8'(-1);                       end
  if (1) begin : y_negp  assign q2 = pv6_106::P8'(-1);             end
  if (1) begin : y_negs  assign q3 = 8'(signed'(-8'sd3));          end
  if (1) begin : y_negsp assign q4 = pv6_106::P8'(signed'(-8'sd3));end
  if (1) begin : y_negb  assign q5 = 32'(-32'sd1);                 end
  if (1) begin : y_negw  assign q6 = pv6_106::P64'(-1);            end
  // full 64-bit patterns onto a 64-bit Lhs
  if (1) begin : y_allf  assign q7 = pv6_106::P64'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : y_msb   assign q8 = pv6_106::P64'(64'h8000_0000_0000_0000); end
  // X / Z operands — neither tool folds; the Rhs must stay an operation
  if (1) begin : y_zz    assign r1 = 8'(6'bzzzzzz);                end
  if (1) begin : y_xx    assign r2 = 8'(6'bxxxxxx);                end
  if (1) begin : y_mixed assign r3 = 8'(6'b1z10x1);                end
  // NON-CAST controls in a gen scope: must be byte-identical patched vs pristine
  if (1) begin : n_lit   assign r4 = 6'h3F;                        end
  if (1) begin : n_par   assign r5 = pv6_106::P8;                  end
  if (1) begin : n_cat   assign r6 = {2'b11, 4'hF};                end
  if (1) begin : n_ones  assign r7 = '1;                           end
  if (1) begin : n_zero  assign r8 = '0;                           end

  assign o = q1[0];
endmodule
