// g11 — a WRITTEN DIM on the chained name: § typeParamNamedElemPackedDim31's
// wrapper must still be built, and the borrow must NOT intercept it.
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t [3:0]
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
