// g7 — the default names a TYPEDEF, not a type parameter: compileTypespec
// resolves it, so the borrow arm is never reached.
typedef logic [5:0] w_t;
module dut #(
    parameter type b_t = w_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
