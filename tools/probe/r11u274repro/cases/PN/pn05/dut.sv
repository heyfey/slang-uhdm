// § pkgNetTsDimEnd274
package pc;
  wire [7:0] a_net [0:1];
  wire [1:0][7:0] a_pkd;
  logic [7:0] a_var [0:1];
endpackage
module dut (output logic [31:0] o);
  import pc::*;
  for (genvar i = 0; i < 1; i++) begin : g
    logic [31:0] a_net; assign a_net = 32'd1;
    logic [31:0] a_pkd; assign a_pkd = 32'd2;
  end
  assign o = g[0].a_net ^ g[0].a_pkd;
endmodule
