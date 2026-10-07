// § pkgElabUnaryFoldOpSpan274
`define NEG -3
package pk;
  parameter int A = `NEG;
endpackage
module dut(output int o);
  assign o = 0;
endmodule
