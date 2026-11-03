interface a_if(input clk, rst);
  logic [31:0] A;
  modport port(input clk, rst, output A);
endinterface
