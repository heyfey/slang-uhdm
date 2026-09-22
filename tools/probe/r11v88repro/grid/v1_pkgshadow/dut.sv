// v11u88 v1 -- LAW C NAME COLLISION: a package parameter read by a net-decl-
// assign whose NAME is also an INTERFACE localparam with a DIFFERENT value.
// The substitution looks the name up in iface->Param_assigns() by NAME.
package pk;
  localparam int K = 5;
endpackage

interface ifc ();
  localparam int K = 9;
  wire [31:0] w_pk = pk::K;
  wire [31:0] w_own = K;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_pk ^ u_if.w_own;
endmodule
