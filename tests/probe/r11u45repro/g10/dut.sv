// g10 — the chain with an OVERRIDE at the instantiation: does the ELAB half
// follow the override through the chain?
module child #(
    parameter type a_t = logic,
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
module dut ( input logic [3:0] i, output logic o );
  child #(.a_t(logic [3:0])) u ( .i(i), .o(o) );
endmodule
