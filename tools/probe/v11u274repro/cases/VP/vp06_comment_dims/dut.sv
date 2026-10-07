// § pkgNetTsDimEnd274
package pk;
  wire [1:0] /* c */ [3:0] n;
  wire [7:0] m /* d */ [0:1];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = n ^ m[0]; endmodule
