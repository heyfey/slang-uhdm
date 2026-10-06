// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
endpackage
module sub (input logic [31:0] a, output logic [31:0] o);
  wire [31:0] w_r = a;
  wire [31:0] w_f = pk::PQ;
  assign o = w_r & w_f;
endmodule
module dut (input logic [31:0] a, output logic [31:0] o);
  sub u_s (.a(a), .o(o));
endmodule
