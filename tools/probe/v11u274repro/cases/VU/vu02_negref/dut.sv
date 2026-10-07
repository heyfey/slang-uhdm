// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int B = 5;
  parameter int A = -B;
  parameter bit N = !B;
endpackage
module dut(output int o, output bit n); assign o = pk::A; assign n = pk::N; endmodule
