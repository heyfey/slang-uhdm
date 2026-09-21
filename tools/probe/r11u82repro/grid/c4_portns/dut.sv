// r11u82 c4 -- LAW B where the module-own namesake is a PORT, and where the
// module-own namesake sits one hop further out than the importing scope.
package pc;
  wire  [7:0] p_net;
  logic [7:0] q_var;
endpackage

module dut (output logic [31:0] o, input wire [15:0] p_net);
  import pc::*;
  logic [15:0] q_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] p_net; assign p_net = 32'd1;
    logic [31:0] q_var; assign q_var = 32'd2;
  end
  assign o = gv[0].p_net ^ gv[0].q_var;
endmodule
