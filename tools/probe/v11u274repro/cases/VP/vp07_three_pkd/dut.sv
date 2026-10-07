// § pkgNetTsDimEnd274
package pk;
  wire [1:0][3:0][2:0] n;
  wire [1:0][3:0] m [2][2];
endpackage
module dut(output logic [23:0] o); import pk::*; assign o = n ^ {16'b0, m[0][1]}; endmodule
