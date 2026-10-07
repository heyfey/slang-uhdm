// § pkgNetKwTypeSignEnd274v
package pk;
  wire logic [1:0][3:0] f;
  wire signed [1:0][3:0] d;
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = f[0] ^ d[1]; endmodule
