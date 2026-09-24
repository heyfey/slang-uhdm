// g15 — SIGNED element, and a chain onto a parameter whose default is signed.
module dut #(
    parameter type a_t = logic signed [7:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
