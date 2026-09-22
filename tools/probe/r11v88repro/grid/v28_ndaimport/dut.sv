// v11u88 v28 -- an interface that IMPORTS a package and reads its parameter
// and enum member in net-decl-assigns (the pass-82 import-hoist ground), with
// a local name that does NOT collide.
package pk;
  typedef enum logic [3:0] { EA, ED = 4 } e_t;
  localparam int PQ = 6;
endpackage

interface ifc ();
  import pk::*;
  localparam int LQ = 2;
  wire [31:0] w_p = PQ;
  wire [31:0] w_e = ED;
  wire [31:0] w_l = LQ;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_p ^ u_if.w_e ^ u_if.w_l;
endmodule
