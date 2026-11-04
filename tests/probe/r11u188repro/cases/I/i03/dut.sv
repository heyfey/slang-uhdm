// § svModeAllFiles188 (InterfaceModPort shapes in SystemVerilog mode: equal at the base)
interface mem_if (input wire clk);
  logic        reset;
endinterface
module top();
logic clk = 0;
mem_if miff(clk);
endmodule
