// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module sub #(parameter int D = 3) (output logic [35:0] o);
  import pk::*;
  wire [31:0] #D w_d = pk::PQ;
  wire [3:0] #D w_e = EB;
  assign o = {w_d, w_e};
endmodule
module dut (output logic [35:0] o);
  sub u_s (.o(o));
endmodule
