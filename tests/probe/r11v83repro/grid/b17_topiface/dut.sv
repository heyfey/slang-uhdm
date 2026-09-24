// v11v83 b17 -- LAW A on a TOP-LEVEL interface (no parent module) that also
// imports a package, beside a module top.  Does the hoist fire, and does the
// top-level elaborated view stay well formed?
package pk;
  wire  [7:0] tn;
  logic [7:0] tv;
endpackage

interface ifc ();
  import pk::*;
  logic [31:0] i_own;
  if (1) begin : gi
    logic [31:0] tn; assign tn = 32'd1;
    logic [31:0] tv; assign tv = 32'd2;
  end
endinterface

module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
