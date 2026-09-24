// r11u83 i4 -- LAW A's PORT-VIEW FENCE.  The same interface is the HOME view
// under work@dut.u_if and a reference-style PORT view under work@dut.u_sub.p.
// Does golden's port view carry the hoisted import group?
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

module sub (ifc p, output logic [31:0] q);
  assign q = p.i_own;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_sub (.p(u_if), .q(o));
endmodule
