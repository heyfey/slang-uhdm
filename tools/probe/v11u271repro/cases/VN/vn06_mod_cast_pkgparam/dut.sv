// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 300;
endpackage
module sub (output logic [7:0] o);
  wire [7:0] w_c = 8'(pk::PQ);
  wire [7:0] w_u = unsigned'(pk::PQ);
  assign o = w_c ^ w_u;
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
