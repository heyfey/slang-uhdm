// r10v106 va4_cast106 — CAST FACES the pass's own g2 does not carry: NESTED
// casts, a cast of a parameter vs a literal, sized and unsized literals under
// and without a cast, concats and replications under a cast, an operand that is
// itself an expression, and the x/z operand that neither tool folds.
// MEASUREMENT ONLY.
package pv4_106;
  parameter int unsigned P8  = 8;
  parameter int unsigned P4  = 4;
  parameter int unsigned P16 = 16;
  parameter int unsigned V63 = 63;
endpackage

module va4_cast106 (output logic o);
  logic [7:0]  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
  logic [3:0]  m1, m2;
  logic [15:0] k1, k2;

  // nested casts, both spellings
  if (1) begin : x_nest_ll assign n1 = 8'(4'(6'h3F));                  end
  if (1) begin : x_nest_pp assign n2 = pv4_106::P8'(pv4_106::P4'(6'h3F)); end
  if (1) begin : x_nest_pl assign n3 = pv4_106::P8'(4'(6'h3F));        end
  if (1) begin : x_nest_lp assign n4 = 8'(pv4_106::P4'(6'h3F));        end
  // concat / replication under a cast
  if (1) begin : x_cat     assign n5 = 8'({2'b11, 4'hF});              end
  if (1) begin : x_rep     assign n6 = 8'({2{3'b101}});                end
  if (1) begin : x_catp    assign n7 = pv4_106::P8'({2'b11, 4'hF});    end
  // a cast of a PARAMETER read vs a LITERAL
  if (1) begin : x_par     assign n8 = 8'(pv4_106::V63);               end
  if (1) begin : x_parp    assign n9 = pv4_106::P8'(pv4_106::V63);     end
  // unsized literal, with and without a cast
  if (1) begin : x_uns     assign n10 = 8'('h3F);                      end
  if (1) begin : x_bare    assign n11 = 'h3F;                          end
  if (1) begin : x_sized   assign n12 = 6'h3F;                         end
  // arithmetic / ternary operands under a cast
  if (1) begin : x_arith   assign m1 = 8'(pv4_106::P8 + 55);           end
  if (1) begin : x_tern    assign m2 = 8'(1 ? 6'h3F : 6'h00);          end
  // widening cast on a narrow Lhs and vice versa
  if (1) begin : x_wide    assign k1 = pv4_106::P16'(6'h3F);           end
  if (1) begin : x_zz      assign k2 = 8'(6'bzzzzzz);                  end

  assign o = n1[0];
endmodule
