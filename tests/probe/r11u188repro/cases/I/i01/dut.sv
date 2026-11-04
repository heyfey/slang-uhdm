// § svModeAllFiles188 (InterfaceModPort shapes in SystemVerilog mode: equal at the base)
interface mem_if (input wire clk);
  logic        reset;
  logic  [7:0] data_sys;
  modport  tb (input clk, output reset, ref data_sys);
endinterface
module top();
logic clk = 0;
mem_if miff(clk);
endmodule
