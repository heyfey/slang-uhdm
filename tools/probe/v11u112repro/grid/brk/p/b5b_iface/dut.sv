interface bus_if(input logic clk);
  logic rst, req, gnt;
  property p_rg;
    @(posedge clk) disable iff (rst) req |-> ##2 gnt;
  endproperty
  a1: assert property (p_rg);
endinterface
module m(input logic clk);
  bus_if u(.clk(clk));
endmodule
