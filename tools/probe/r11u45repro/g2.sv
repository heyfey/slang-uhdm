// g2 — depth-2 chain: does the third link reach the FIRST object?
module dut #(
    parameter type a_t = logic [3:0],
    parameter type b_t = a_t,
    parameter type c_t = b_t
) ( input c_t i, output logic o );
  assign o = ^i;
endmodule
