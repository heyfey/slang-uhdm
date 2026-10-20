// § ifPortViewArithIntForm419
interface i(input clk);
  parameter W = 120;
  parameter S = W*8-1;
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
