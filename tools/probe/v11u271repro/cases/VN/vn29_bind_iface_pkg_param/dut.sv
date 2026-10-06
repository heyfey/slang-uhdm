// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
interface ifc ();
  import pk::*;
  wire [31:0] w_q = PQ;
  wire [3:0] w_e = pk::EB;
endinterface
module dut (input logic [31:0] a, output logic o);
  assign o = a[0];
endmodule
bind dut ifc u_i ();
