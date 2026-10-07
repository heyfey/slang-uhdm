// § pkgNetTsDimEnd274
package pk;
  wire [0:7] a [1:0];
  wire [0:1][0:3] b;
  wire signed c [0:1][0:1];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = a[0] ^ b ^ {7'b0, c[0][0]}; endmodule
