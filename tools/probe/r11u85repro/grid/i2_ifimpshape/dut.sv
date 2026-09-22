// r11u83 i2 -- LAW A: THE IMPORT SHAPES AND THE NEGATIVES, in an interface.
// wildcard, EXPLICIT item (and its unnamed sibling), TRANSITIVE hop, a
// package nobody imports, and a $unit net.  GOLDEN WRITES NOTHING ON A MISS.
package pa;
  wire  [31:0] a_net;
  logic [31:0] a_var;
endpackage
package pb;
  import pa::*;
  wire  [31:0] b_net;
endpackage
package pc;
  wire  [31:0] c_net;
  wire  [31:0] c_unread;
endpackage
package pz;
  wire  [31:0] z_net;
endpackage

wire [31:0] unitnet;

interface ifc ();
  import pb::*;
  import pc::c_net;
  logic [31:0] i_own;
  if (1) begin : gi
    logic [31:0] a_net;    assign a_net    = 32'd1;
    logic [31:0] b_net;    assign b_net    = 32'd2;
    logic [31:0] c_net;    assign c_net    = 32'd3;
    logic [31:0] c_unread; assign c_unread = 32'd4;
    logic [31:0] z_net;    assign z_net    = 32'd5;
    logic [31:0] unitnet;  assign unitnet  = 32'd6;
  end
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.i_own;
endmodule
