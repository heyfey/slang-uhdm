// § macroIfaceRangeSelBaseTok256 (a virtual-interface path in a class task through this.)
`define wr(LSB) \
  this.vif.read_data[LSB+:4] = 4'h3;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
class drv; virtual bif vif; task run(); `wr(2) endtask endclass
module top; bif b(); initial begin drv d = new; d.vif = b; d.run(); end endmodule
