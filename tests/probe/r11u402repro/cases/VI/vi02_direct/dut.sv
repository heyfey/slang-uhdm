// § vifVarNotElaborated402
interface SyncBus(input logic clk);
  logic a;
endinterface
module top;
  virtual SyncBus v;
endmodule
