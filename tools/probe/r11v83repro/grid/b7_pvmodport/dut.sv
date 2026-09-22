// v11u83 b7 -- LAW A's PORT VIEW, modport-qualified.  The port view runs the
// shared builder with a THROWAWAY net vector, so its hoisted NET holders are
// minted and filed in netMap but listed nowhere.  Does anything in the port
// view bind one of those orphans?
package pk;
  wire  [7:0] k_net;
  logic [7:0] k_var;
endpackage

interface ifc ();
  import pk::*;
  logic [15:0] k_net;
  logic [15:0] k_var;
  logic [15:0] i_own;
  modport mp (input k_net, input k_var, output i_own);
endinterface

module sub (ifc.mp p, output logic [31:0] o);
  assign o = {16'd0, p.k_net};
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_sub (.p(u_if.mp), .o(o));
endmodule
