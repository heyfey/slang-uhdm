// g6 — FORWARD reference: the named parameter is declared AFTER.  Surelog's
// `*parameters` holds only the earlier ones, so nothing is borrowed.
module dut #(
    parameter type b_t = a_t,
    parameter type a_t = logic [1:0]
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
