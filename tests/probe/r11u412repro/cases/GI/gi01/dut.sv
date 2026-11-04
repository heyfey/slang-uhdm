// § genericIfacePosConnNoDouble412
interface sb (input logic clk);
  logic req;
endinterface
module mm(interface a);
  logic av;
  always @(posedge a.clk) av <= a.req;
endmodule
module top;
  logic clk = 0;
  sb s(clk);
  mm u(s);
endmodule
