// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
interface ifc ();
  import pk::*;
  wire [31:0] w_q = PQ;
  wire [3:0] w_e = EB;
  modport mp (input w_q, input w_e);
endinterface
module sub (ifc.mp i, output logic [31:0] o);
  assign o = i.w_q ^ i.w_e;
endmodule
module dut (output logic [63:0] o);
  ifc u_a ();
  ifc u_b ();
  sub u_s (.i(u_a.mp), .o(o[31:0]));
  sub u_t (u_b, o[63:32]);
endmodule
