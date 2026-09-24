// v11u82 w6 -- LAW B BREAK: the colliding module is instantiated TWICE, so
// each elaborated copy has its own hoisted package objects.  A shared pointer
// across instances would show here.
package pc;
  wire  [7:0] c_net;
  logic [7:0] c_var;
endpackage

module cel (output logic [31:0] o);
  import pc::*;
  wire  [15:0] c_net;
  logic [15:0] c_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] c_net; assign c_net = 32'd1;
    logic [31:0] c_var; assign c_var = 32'd2;
  end
  assign o = gv[0].c_net ^ gv[0].c_var;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] a, b;
  cel u1 (.o(a));
  cel u2 (.o(b));
  assign o = a ^ b;
endmodule
