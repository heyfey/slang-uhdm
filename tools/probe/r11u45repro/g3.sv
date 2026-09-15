// g3 — the chained-FROM parameter's default is a TYPEDEF name.
typedef logic [7:0] v_t;
module dut #(
    parameter type a_t = v_t,
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
