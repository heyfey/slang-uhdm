// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
endpackage
module sub (output logic [31:0] o);
  import pk::*;
  wire [31:0] w_p = PQ;
  assign o = w_p;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
