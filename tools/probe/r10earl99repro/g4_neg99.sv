// r10earl99 g4 -- THE NEGATIVES: every place an unbased unsized literal must
// KEEP its own encoding after this pass, and every non-struct pattern target.
package u99;
  typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
endpackage

module g4_neg99 (
  input  logic          clk,
  input  logic          sel,
  input  u99::s_t       d,
  output logic [7:0]    n_assign,     // plain ternary arm, no pattern
  output logic [7:0]    n_bin,        // inside an arithmetic operand
  output logic          n_cmp,        // a comparison operand
  output logic [7:0]    n_cat,        // inside a concat
  output logic [7:0]    n_idx,        // inside an index expression
  output u99::s_t       n_proc,       // PROCEDURAL assignment of a pattern
  output logic [3:0]    n_parr,       // PACKED-ARRAY pattern target
  output logic [7:0]    n_deep        // pattern under an arm's arithmetic
);
  logic [3:0] parr;
  always_comb begin
    n_proc = sel ? d : '{a: '1, b: '0};   // NOT a cont_assign carrier
  end
  assign n_assign = sel ? 8'hff : '1;
  assign n_bin    = sel ? 8'h00 : ('1 + 8'd1);
  assign n_cmp    = ('1 == sel);
  assign n_cat    = {4'h0, {4{'1}}};
  assign n_idx    = {7'b0, d.b['1]};
  assign n_parr   = sel ? 4'h0 : '{'1, '0, '1, '0};
  assign n_deep   = sel ? 8'h00 : (8'(u99::s_t'('{a: '1, b: '0})) + 8'd1);
endmodule
