// r10v225 arm v1_qbound — THE QUEUE MAX-BOUND FACE.
// `makeIfaceDefArrayNet225`'s queue arm splits on `q.maxBound && boundSyn`, so a
// bound that EVALUATES TO ZERO would fall into the UNBOUNDED `[$]` shape.
// MEASURED: slang REJECTS `[$:0]` and `[$:<zero param>]` outright ("value must
// be positive"), so `maxBound == 0` is equivalent to "unbounded" and the split
// cannot be reached with a written bound.  What remains testable is the bound
// EXPRESSION forms: a literal, a parameter, an arithmetic expression, a large
// literal, and a sized/based literal.
interface if225v_q();
  localparam int PN = 3;
  typedef logic [7:0] tvq_t;
  tvq_t q_plain   [$];
  tvq_t q_one     [$:1];
  tvq_t q_three   [$:3];
  tvq_t q_pn      [$:PN];
  tvq_t q_expr    [$:PN-1];
  tvq_t q_big     [$:255];
  tvq_t q_based   [$:8'd7];
endinterface

module top225v_q(); endmodule
