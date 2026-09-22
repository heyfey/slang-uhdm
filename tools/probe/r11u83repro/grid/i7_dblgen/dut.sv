// r11u83 i7 -- LAW A meets the GENERIC-INTERFACE-PORT DOUBLING.  An interface
// bound to a PLAIN `interface` port lists its variables TWICE; does the
// hoisted group double with them?  (The call site's placement -- before or
// after the doubling -- is decided by this arm, not by analogy.)
package pk;
  logic [31:0] k_var;
  wire  [31:0] k_net;
endpackage

interface ifc ();
  import pk::*;
  logic [31:0] i_own;
endinterface

module gsub (interface g, output logic [31:0] q);
  assign q = g.i_own;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  gsub u_g (.g(u_if), .q(o));
endmodule
