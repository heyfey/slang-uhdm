// § ifaceArrPortElemViewNamedByArray200
interface bus (input logic clk);
  logic [3:0] data;
  wire w;
  modport mp (input clk, input data, output w);
endinterface
module sub (bus.mp b [2]);
  assign b[0].w = b[0].data[0];
  assign b[1].w = b[1].data[1];
endmodule
module i01 (input logic clk);
  bus bi [2] (clk);
  sub u (bi);
endmodule
