// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
endpackage
module sub (output logic [31:0] o);
  wire [31:0] #2 w_d = pk::PQ;
  assign o = w_d;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
