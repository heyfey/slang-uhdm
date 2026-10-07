// § pkgNetTsDimEnd274
package pk;
  localparam int W = 4;
  wire [W-1:0][1:0] n;
  wire [W-1:0] m [W];
endpackage
module dut(output logic [7:0] o); import pk::*; assign o = n ^ {4'b0, m[1]}; endmodule
