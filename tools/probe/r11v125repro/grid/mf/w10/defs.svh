`define LEAF(n) \
module n(input logic a, output logic o); \
  assign o = ~a; \
endmodule
