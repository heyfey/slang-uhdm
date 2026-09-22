// r11u83 i5 -- LAW A across TWO elaborated copies of the same interface: one
// hoisted holder per instance, no pointer shared between them.
package pk;
  wire  [31:0] k_net;
  logic [31:0] k_var;
endpackage

interface ifc ();
  import pk::*;
  logic [31:0] i_own;
  if (1) begin : gi
    logic [31:0] k_net; assign k_net = 32'd1;
    logic [31:0] k_var; assign k_var = 32'd2;
  end
endinterface

module dut (output logic [31:0] o1, o2);
  ifc u_a ();
  ifc u_b ();
  assign o1 = u_a.i_own;
  assign o2 = u_b.i_own;
endmodule
