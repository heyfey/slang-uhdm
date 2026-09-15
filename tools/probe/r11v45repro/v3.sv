// v3 — SHADOW: a compilation-unit typedef with the SAME NAME as the earlier
// type parameter.  The borrow must take the PARAMETER's object, not the
// typedef's, and must not mis-resolve.
typedef logic [7:0] a_t;
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
