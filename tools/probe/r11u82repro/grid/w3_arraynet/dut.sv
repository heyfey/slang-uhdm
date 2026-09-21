// v11u82 w3 -- LAW B BREAK: the imported package copy is an UNPACKED ARRAY
// net/var, which the caller's array fence refuses to resolve.  The fallback
// must hand the cell back to the module's own object, never to nothing.
package pc;
  wire  [7:0] a_net [0:1];
  logic [7:0] a_var [0:1];
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire  [15:0] a_net;
  logic [15:0] a_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] a_net; assign a_net = 32'd1;
    logic [31:0] a_var; assign a_var = 32'd2;
  end
  assign o = gv[0].a_net ^ gv[0].a_var;
endmodule
