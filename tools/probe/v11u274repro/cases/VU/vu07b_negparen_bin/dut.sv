// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int B = 2;
  parameter int A = -(B + 1);
  parameter int C = ~(B << 1);
endpackage
module dut(output int o); assign o = 0; endmodule
