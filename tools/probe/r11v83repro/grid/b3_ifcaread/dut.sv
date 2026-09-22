// v11u83 b3 -- LAW A BREAK: the interface body's own cont_assign READS an
// imported package variable.  The def cont_assign refs are rebound through
// netToVar (ModuleEmit ~39171), whose source map netMap the hoist now fills.
package pk;
  logic [7:0] pv;
  wire  [7:0] pn;
endpackage

interface ifc ();
  import pk::*;
  logic [15:0] w;
  logic [15:0] x;
  assign w = {8'd0, pv};
  assign x = {8'd0, pn};
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = {u_if.w, u_if.x};
endmodule
