// v1 — BOTH links overridden at the instantiation (def view must still borrow,
// elab view must follow each override independently).
module child #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
module dut ( input logic [3:0] i, output logic o );
  child #(.a_t(logic [3:0]), .b_t(logic [3:0])) u ( .i(i), .o(o) );
endmodule
