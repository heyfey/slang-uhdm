// r11u82 c3 -- LAW B with an EXPLICIT import.  An explicit import colliding
// with a module-own declaration of the same name is not legal SV, so the
// collision here is between the explicit import and a GEN-LOCAL namesake only;
// the module declares a DIFFERENT name.  Both rc values are recorded.
package pc;
  wire  [7:0] e_net;
  logic [7:0] e_var;
endpackage

module dut (output logic [31:0] o);
  import pc::e_net;
  import pc::e_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] e_net; assign e_net = 32'd1;
    logic [31:0] e_var; assign e_var = 32'd2;
  end
  assign o = gv[0].e_net ^ gv[0].e_var;
endmodule
