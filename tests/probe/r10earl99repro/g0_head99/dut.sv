// r10earl99 g0 -- THE HEAD WITNESS, minimal.
// hmac_core.sv:114-119 in miniature: a cont_assign whose RHS is a NESTED
// conditional chain, two of whose arms are `'{...}` patterns with an unbased
// `'1` on a 4-bit struct member.  `out_b` is the CONTROL: the same pattern
// written DIRECTLY as the RHS, which the landed § patFlatUnsizedMemberWidth61
// already re-types (the carrier gate reaches it).
package p99;
  typedef logic [31:0] w32_t;
  typedef struct packed {
    w32_t       data;
    logic [3:0] mask;
  } fifo_t;
endpackage

module g0_head99 (
  input  logic [1:0]   sel,
  input  p99::fifo_t   in_d,
  input  logic [255:0] big,
  output p99::fifo_t   out_a,
  output p99::fifo_t   out_b,
  output p99::fifo_t   out_c
);
  // A: the head shape -- ternary chain with pattern arms.
  assign out_a =
    (sel == 2'd0) ? in_d                                :
    (sel == 2'd1) ? '{data: big[255-:32], mask: '1}     :
    (sel == 2'd2) ? in_d                                :
    '{default: '0};

  // B: the CONTROL -- pattern directly the RHS (already equal today).
  assign out_b = '{data: big[255-:32], mask: '1};

  // C: a SINGLE ternary, pattern in BOTH arms.
  assign out_c = (sel == 2'd3) ? '{data: big[63-:32], mask: '1}
                               : '{data: big[31-:32], mask: '0};
endmodule
