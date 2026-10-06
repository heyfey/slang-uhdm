// § ndaLawLhsTsDeferred271v
package pk;
  localparam int PQ = 6;
endpackage
module chk (input logic [31:0] a, output logic f);
  wire [31:0] w_p = pk::PQ;
  assign f = (a == w_p);
endmodule
module dut (input logic [31:0] a, output logic o);
  assign o = a[0];
endmodule
bind dut chk u_chk (.a(a), .f());
