// § ndaImpEnumConstUnlocated271
package pk;
  typedef enum logic [3:0] { EA, ED = 4 } e_t;
  localparam int PQ = 6;
endpackage
interface ifc ();
  import pk::*;
  wire [31:0] w_e = ED;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_e;
endmodule
