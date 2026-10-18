// § taggedVoidMemberTs402
module top;
  typedef union tagged packed { void A; bit [3:0] B; } tp_t;
  tp_t t;
endmodule
