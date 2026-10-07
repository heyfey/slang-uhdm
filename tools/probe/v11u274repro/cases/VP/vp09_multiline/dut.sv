// § pkgNetTsDimEnd274
package pk;
  wire [1:0]
       [3:0] n;
  wire [7:0] m
       [0:1];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = n ^ m[1]; endmodule
