// § ndaLawLhsTsDeferred271v
package pk;
  localparam int PQ = 6;
endpackage
module chk (input logic [31:0] a, output logic f);
  wire [31:0] w_p = pk::PQ;
  wire [7:0] w_v = pk::PQ;
  assign f = (a == w_p) ^ w_v[1];
endmodule
module sub (input logic [31:0] a, output logic o);
  assign o = a[1];
endmodule
module dut (input logic [31:0] a, output logic [1:0] o);
  sub u_a (.a(a), .o(o[0]));
  sub u_b (.a(a), .o(o[1]));
endmodule
bind sub chk u_chk (.a(a), .f());
