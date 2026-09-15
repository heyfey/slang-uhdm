// v20 — SHADOW by a typedef declared in the SAME FILE but AFTER the module
// (the $unit typedef is visible to the whole unit).
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
typedef logic [1:0] a_t;
