// v11u88 v2 -- LAW C NAME COLLISION 2: a package ENUM MEMBER whose name is
// also an interface localparam with a different value.
package pk;
  typedef enum logic [3:0] { EA, EB = 2 } e_t;
endpackage

interface ifc ();
  localparam int EB = 9;
  wire [31:0] w_e = pk::EB;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_e;
endmodule
