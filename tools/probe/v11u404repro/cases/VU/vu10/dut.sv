// § undefaultedDefInvalidInst404
interface ifc #(parameter w) (input clk);
  logic [w-1:0] d;
endinterface
module dut #(parameter p) (input clk);
  logic [p:0] q;
endmodule
module top; endmodule
