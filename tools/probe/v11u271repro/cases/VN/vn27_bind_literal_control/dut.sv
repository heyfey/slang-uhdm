// § ndaConstRhsFreshLhs271
module chk (input logic [31:0] a, output logic f);
  wire [31:0] w_l = 6;
  wire [31:0] w_o = a + 1;
  assign f = (a == w_l) ^ w_o[0];
endmodule
module dut (input logic [31:0] a, output logic o);
  assign o = a[0];
endmodule
bind dut chk u_chk (.a(a), .f());
