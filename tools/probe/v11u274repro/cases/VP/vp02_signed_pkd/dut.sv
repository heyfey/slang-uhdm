// § pkgNetKwTypeSignEnd274v
package pk;
  wire signed [1:0][7:0] n;
  wire logic [1:0][3:0] m;
endpackage
module dut(output logic [15:0] o, output logic [7:0] p); import pk::*; assign o = n; assign p = m; endmodule
