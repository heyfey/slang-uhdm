// § pkgElabUnaryFoldOpSpan274
`define THREE 3
`define NEGM(x) -x
package pk;
  parameter int A = -`THREE;
  parameter int B = `NEGM(4);
endpackage
module dut(output int o, output int b); assign o = pk::A; assign b = pk::B; endmodule
