// v7 — TWO INSTANCES of the same definition with DIFFERENT overrides: the one
// shared def-view object must not be corrupted by either.
module child #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
module dut ( input logic [3:0] i, output logic o1, output logic o2 );
  child #(.a_t(logic [3:0])) u1 ( .i(i), .o(o1) );
  child #(.a_t(logic [1:0])) u2 ( .i(i[1:0]), .o(o2) );
endmodule
