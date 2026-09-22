// r11u83 i3 -- THE TRANSITIVE HOP'S NAMESAKE BIND, module home, as the
// CONTROL for the interface row of i2_ifimpshape: pa's net reaches the
// importer only through pb, and the question is whether the gen-scope cell
// BINDS the hoisted copy on the module side either.
package pa;
  wire  [31:0] a_net;
  logic [31:0] a_var;
endpackage
package pb;
  import pa::*;
  wire  [31:0] b_net;
endpackage

module dut (output logic [31:0] o);
  import pb::*;
  logic [31:0] m_own;
  if (1) begin : gm
    logic [31:0] a_net; assign a_net = 32'd1;
    logic [31:0] a_var; assign a_var = 32'd2;
    logic [31:0] b_net; assign b_net = 32'd3;
  end
  assign o = m_own;
endmodule
