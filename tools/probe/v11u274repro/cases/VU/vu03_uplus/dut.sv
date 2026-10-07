// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = +3;
  parameter int C = +(-3);
endpackage
module dut(output int o, output int c); assign o = pk::A; assign c = pk::C; endmodule
