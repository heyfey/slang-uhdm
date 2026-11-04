// § ndaConstRhsFreshLhs271
package pk;
  typedef enum logic [3:0] { EA, ED = 4 } e_t;
endpackage
interface ifc ();
  wire [31:0] w_e = pk::ED;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_e;
endmodule
