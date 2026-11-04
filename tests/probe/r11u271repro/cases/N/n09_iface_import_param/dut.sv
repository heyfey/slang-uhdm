// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
endpackage
interface ifc ();
  import pk::*;
  wire [31:0] w_p = PQ;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_p;
endmodule
