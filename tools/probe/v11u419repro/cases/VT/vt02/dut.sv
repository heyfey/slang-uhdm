// § ifPortViewTdAliasDefName419
interface i(input clk);
  typedef logic [3:0] f_t;
  parameter f_t A = 5;
  logic [7:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i u(clk);
  dut d(u);
endmodule
