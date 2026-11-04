// § pkgNetTsDimEnd274
package pk;
  wire [7:0] a [0:1], b;
  wire [1:0][3:0] c, d [3];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = a[1] ^ b ^ c ^ d[0]; endmodule
