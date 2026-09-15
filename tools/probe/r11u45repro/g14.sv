// g14 — TWO independent chains in one list, and a chain whose source is itself
// chained from a typedef: the record must be per-NAME, not per-list.
typedef logic [3:0] n_t;
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t,
    parameter type c_t = n_t,
    parameter type d_t = c_t
) ( input b_t i, input d_t j, output logic o );
  assign o = ^i ^ ^j;
endmodule
