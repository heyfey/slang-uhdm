// v11u83 b16 -- the PRE-EXISTING clone shapes with a delay and a strength:
// a plain-constant Rhs and a package-enum-const Rhs already take the elab
// clone at the base.  Does golden's elab view carry the DELAY and the
// STRENGTH on them, and does the base clone?
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

interface ifc ();
  logic [31:0] k_del;
  logic [31:0] k_str;
  assign #5 k_del = 32'd7;
  assign (strong1, weak0) k_str = pk::EB;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.k_del ^ u_if.k_str;
endmodule
