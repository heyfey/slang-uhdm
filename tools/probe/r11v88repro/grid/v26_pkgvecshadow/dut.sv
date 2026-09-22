// v11u88 v26 -- collision on a package localparam of a TYPEDEF'd vector type
// and on an enum member, both read by net-decl-assigns in an interface whose
// own localparams carry the same names.
package pk;
  typedef logic [15:0] v_t;
  typedef enum logic [3:0] { EA, EC = 3 } e_t;
  localparam v_t PV = 16'h1234;
endpackage

interface ifc ();
  localparam int PV = 9;
  localparam int EC = 8;
  wire [31:0] w_pv = pk::PV;
  wire [31:0] w_ec = pk::EC;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_pv ^ u_if.w_ec;
endmodule
