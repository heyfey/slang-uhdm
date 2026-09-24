// v11u82 w4 -- LAW B BREAK: TWO wildcard-imported packages both hold the name
// and the module declares its own, so no reference is ambiguous.  Which copy
// does the producer hoist first, and which does the law pick?
package pa;
  wire  [7:0] d_net;
  logic [7:0] d_var;
endpackage
package pb;
  wire  [3:0] d_net;
  logic [3:0] d_var;
endpackage

module dut (output logic [31:0] o);
  import pa::*;
  import pb::*;
  wire  [15:0] d_net;
  logic [15:0] d_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] d_net; assign d_net = 32'd1;
    logic [31:0] d_var; assign d_var = 32'd2;
  end
  assign o = gv[0].d_net ^ gv[0].d_var;
endmodule
