// r11u83 i9 -- DOES THE GENERIC-PORT DOUBLING DOUBLE THE *NETS* TOO, and is
// that an interface's OWN nets or only the hoisted ones?  The interface here
// carries BOTH, so golden answers the question with the other side held
// fixed.  (i7_dblgen has no own net and so cannot separate them.)
package pk;
  logic [31:0] k_var;
  wire  [31:0] k_net;
endpackage

interface ifc ();
  import pk::*;
  wire  [31:0] o_net;
  logic [31:0] i_own;
endinterface

module gsub (interface g, output logic [31:0] q);
  assign q = g.i_own;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  gsub u_g (.g(u_if), .q(o));
endmodule
