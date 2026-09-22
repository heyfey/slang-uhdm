// r11u85 a2 -- LAW A: the PRE-EXISTING elab-clone shape #2, a PACKAGE
// ENUM-CONST Rhs (the shape that mints a fresh folded constant), crossed with
// the same drive fields.
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

interface ifc ();
  logic [31:0] e_none;
  logic [31:0] e_del;
  logic [31:0] e_str;
  assign e_none = pk::EB;
  assign #5 e_del = pk::EB;
  assign (strong1, weak0) e_str = pk::EB;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.e_none ^ u_if.e_del ^ u_if.e_str;
endmodule
