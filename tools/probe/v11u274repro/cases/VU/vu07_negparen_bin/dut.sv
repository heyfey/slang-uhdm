// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int B = 2;
  parameter int A = -(B + 1);
  parameter int C = ~(B << 1);
endpackage
module dut(output int o, output int c); assign o = pk::A; assign c = pk::C; endmodule
