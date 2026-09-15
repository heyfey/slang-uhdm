// v19 — SHADOW through a WILDCARD PACKAGE IMPORT: does golden bind the bare
// name to the imported typedef too, or only to a $unit typedef?
package pk;
  typedef logic [1:0] a_t;
endpackage
module dut
  import pk::*;
#(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
