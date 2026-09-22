// v11v83 b19 -- LAW A x the generic-port DOUBLING x pass-80's COLLIDE.  The
// interface imports a package whose names collide with its own, is handed to
// a PLAIN generic interface port (so its variables are listed twice), and a
// gen-scope cell writes the namesake.  Which copy does each view bind?
package pk;
  wire  [7:0] q_net;
  logic [7:0] q_var;
endpackage

interface ifc ();
  import pk::*;
  wire  [15:0] q_net;
  logic [15:0] q_var;
  logic [31:0] i_own;
  for (genvar i = 0; i < 1; i = i + 1) begin : gi
    logic [31:0] q_net; assign q_net = 32'd1;
    logic [31:0] q_var; assign q_var = 32'd2;
  end
endinterface

module gsub (interface g, output logic [31:0] o);
  assign o = g.i_own;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  gsub u_g (.g(u_if), .o(o));
endmodule
