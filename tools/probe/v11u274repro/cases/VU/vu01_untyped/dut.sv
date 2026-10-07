// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter A = -3;
  localparam B = ~4'h3;
endpackage
module dut(output int o, output logic [3:0] p); assign o = pk::A; assign p = pk::B; endmodule
