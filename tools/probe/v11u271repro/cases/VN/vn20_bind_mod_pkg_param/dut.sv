// § ndaLawLhsTsDeferred271v
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module chk (input logic [31:0] a, output logic f);
  import pk::*;
  wire [31:0] w_p = pk::PQ;
  wire [3:0] w_e = EB;
  assign f = (a == w_p) ^ w_e[0];
endmodule
module dut (input logic [31:0] a, output logic o);
  assign o = a[0];
endmodule
bind dut chk u_chk (.a(a), .f());
