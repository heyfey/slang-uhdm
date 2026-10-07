// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -int'(3);
  parameter logic [7:0] B = ~8'(3);
endpackage
module dut(output int o, output logic [7:0] p); assign o = pk::A; assign p = pk::B; endmodule
