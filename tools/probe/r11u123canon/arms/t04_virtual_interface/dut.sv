interface bus_if(input logic clk);
  logic [7:0] data;
  logic       valid;
endinterface
class driver;
  virtual bus_if vif;
  virtual bus_if vif2;
  function new(virtual bus_if v); vif = v; vif2 = v; endfunction
  task drive(); @(posedge vif.clk); vif.valid <= 1; vif2.data <= 8'h5a; endtask
endclass
module top(input logic clk);
  bus_if b(clk);
  driver d;
  initial begin d = new(b); d.drive(); end
endmodule
