// § impCondFlipTakenLeaf242
// The package in an included file, the taken leaf macro-born there; arithmetic leaf LB + 1.
`include "fp.svh"
module top import fp::*; #(parameter int P = 1) (input logic [7:0] a, output logic [W-1:0] o, output logic [Z-1:0] z);
  assign o = a[W-1:0];
  assign z = a[Z-1:0];
endmodule
