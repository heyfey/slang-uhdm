// v11 — UNPACKED dim written on the chained name (the mirror of g11's packed).
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i [0:1], output logic o );
  assign o = ^i[0] ^ ^i[1];
endmodule
