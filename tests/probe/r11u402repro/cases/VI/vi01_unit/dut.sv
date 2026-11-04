// § virtIfaceTd402
interface SyncBus(input logic clk);
  logic a;
endinterface
typedef virtual SyncBus VI;
module top;
  VI v;
endmodule
