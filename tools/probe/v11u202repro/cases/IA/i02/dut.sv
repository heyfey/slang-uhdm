// § ifaceArrPortElemViewNamedByArray200
interface bus (input logic clk);
  logic [3:0] data;
  modport mp (input clk, output data);
endinterface
program prg (bus.mp b [1:0]);
  initial b[0].data = 4'h1;
endprogram
module sub (bus b [1:0]);
endmodule
module i02 (input logic clk);
  bus bi [1:0] (clk);
  prg p (bi);
  sub s (.b(bi));
endmodule
