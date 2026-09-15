// v4 — the earlier parameter's default is a pass-31 WRITTEN-DIM wrapper, and
// the chain borrows THAT (a packed_array_typespec, not a logic_typespec).
typedef logic [3:0] e_t;
module dut #(
    parameter type a_t = e_t [3:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i[0];
endmodule
