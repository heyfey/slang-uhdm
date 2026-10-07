// § pkgNetTsDimEnd274
package pk;
  wire [7:0] a [0:1][0:3];
  wire b [2][3];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = a[0][1] ^ {7'b0, b[1][2]}; endmodule
