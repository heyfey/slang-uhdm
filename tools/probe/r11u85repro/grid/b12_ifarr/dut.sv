// v11u83 b12 -- LAW A: an INTERFACE ARRAY whose element imports a package.
// Each element is its own elaborated view; does every one carry the hoisted
// group once, and do the array's port views stay right?
package pk;
  wire  [7:0] an;
  logic [7:0] av;
endpackage

interface ifc ();
  import pk::*;
  logic [31:0] i_own;
  if (1) begin : gi
    logic [31:0] an; assign an = 32'd1;
    logic [31:0] av; assign av = 32'd2;
  end
endinterface

module sub (ifc p, output logic [31:0] q);
  assign q = p.i_own;
endmodule

module dut (output logic [31:0] o);
  ifc u_arr [0:1] ();
  sub u_s0 (.p(u_arr[0]), .q());
  assign o = u_arr[1].i_own;
endmodule
