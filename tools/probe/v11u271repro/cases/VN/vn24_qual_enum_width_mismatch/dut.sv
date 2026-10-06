// § ndaConstRhsFreshLhs271
package pk;
  typedef enum logic [3:0] { EA = 4'hA, EB = 4'h5 } e_t;
endpackage
module sub (output logic [9:0] o);
  wire [7:0] w_w = pk::EA;
  wire [1:0] w_n = pk::EB;
  assign o = {w_w, w_n};
endmodule
interface ifc ();
  import pk::*;
  wire [7:0] i_w = EA;
  wire [1:0] i_n = pk::EB;
endinterface
module dut (output logic [19:0] o);
  sub u_s (.o(o[9:0]));
  ifc u_i ();
  assign o[19:10] = {u_i.i_w, u_i.i_n};
endmodule
