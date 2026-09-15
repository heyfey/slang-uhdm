// v17 — SHADOW whose typedef has the SAME CANONICAL TYPE as the type
// parameter.  Pristine's makeTypeParamDefaultTs canonical fallback can land on
// the typedef's object, which is the object GOLDEN uses here; the borrow would
// take the parameter's own object instead.  The pristine-right/patched-wrong
// probe.
typedef logic [1:0] a_t;
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
