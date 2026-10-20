// § ifPortViewArithIntForm419
interface i #(parameter N = 4) (input clk);
  localparam M = N*8-1;
  logic [M:0] d;
  modport port(input clk, d);
endinterface
module dut(i.port x);
endmodule
module top;
  logic clk;
  i #(.N(3)) u(clk);
  dut d(u);
endmodule
