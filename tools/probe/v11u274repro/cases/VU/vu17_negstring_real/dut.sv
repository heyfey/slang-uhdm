// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter real R = -(2.5);
  parameter shortreal S = -1.0;
  parameter longint L = -64'sd9;
endpackage
module dut(output real o, output longint l); assign o = pk::R; assign l = pk::L; endmodule
