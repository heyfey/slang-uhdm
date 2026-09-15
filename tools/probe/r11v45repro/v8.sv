// v8 — the chained type used by a $bits() in a VALUE parameter of the same
// list (the corpus row's own shape, minimised).
module dut #(
    parameter type id_t      = logic [1:0],
    parameter type resp_id_t = id_t,
    parameter int  DEPTH     = (1 << $bits(resp_id_t)),
    parameter type rt_t      = resp_id_t [DEPTH-1:0]
) ( input rt_t i, output logic o );
  assign o = ^i;
endmodule
