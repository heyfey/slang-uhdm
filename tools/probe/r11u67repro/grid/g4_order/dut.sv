// g4 - IS THE GOLDEN ANSWER DECIDED BY THE TYPEDEF NAMES' SORT ORDER?
// HYPOTHESIS (Surelog ElaborationStep.cpp:102-190 bindTypedefs_): each scope's
// typedefs are walked in the NAME-SORTED order of DesignComponent::
// getTypeDefMap(); a typedef written over a NAMED type carries a DummyType and
// is rebound to its TARGET'S DataType AS IT STANDS AT THAT MOMENT
// (`typd->setDefinition(def); typd->setDataType((DataType*)def);`, :186-189).
// The signal rewrite at :1487-1500 then stamps a net type only when that
// DataType's category is SIMPLE_TYPEDEF -- an unbound target is still DUMMY.
// So the SAME SHAPE must answer 36 or 0 purely by how the two names SORT.
// Textual order is identical in both cells; only the names differ.
module ordm (output logic [1:0] o);
  typedef logic [1:0] p_t;      // SimpleType (never needs binding)
  typedef p_t         zq_t;     // dummy; sorts LAST
  typedef zq_t        ab_t [2]; // "ab_t" < "zq_t": binds BEFORE zq_t -> PREDICT 0
  typedef p_t         aq_t;     // dummy; sorts EARLY
  typedef aq_t        zb_t [2]; // "aq_t" < "zb_t": aq_t bound FIRST -> PREDICT 36
  ab_t y;
  zb_t x;
  assign o = y[0] | x[0];
endmodule
module ordi0 (output logic [1:0] o);  // the PREDICT-0 cell ALONE in its module
  typedef logic [1:0] p_t;
  typedef p_t         zq_t;
  typedef zq_t        ab_t [2];
  ab_t y; assign o = y[0];
endmodule
module ordi1 (output logic [1:0] o);  // the PREDICT-36 cell ALONE in its module
  typedef logic [1:0] p_t;
  typedef p_t         aq_t;
  typedef aq_t        zb_t [2];
  zb_t x; assign o = x[0];
endmodule
module dut (output logic [1:0] o);
  logic [1:0] a, b, c;
  ordm um (.o(a)); ordi0 u0 (.o(b)); ordi1 u1 (.o(c));
  assign o = a | b | c;
endmodule
