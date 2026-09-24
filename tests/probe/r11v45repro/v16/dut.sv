// v16 — TWO definitions in one file whose chains use the SAME parameter names
// (the per-list record must not leak across scopes), one of them nested as an
// instance of the other.
module inner #(
    parameter type a_t = logic [3:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  logic o1;
  inner #() u ( .i({2'b0, i}), .o(o1) );
  assign o = o1 ^ ^i;
endmodule
