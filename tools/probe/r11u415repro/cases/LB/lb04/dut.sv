// § labeledCallStmtLabelDropped415
interface bus_if;
  logic [7:0] d;
  task Read(input logic [7:0] r); d = r; endtask
  modport m(import Read);
endinterface
module cpu(bus_if.m b, input logic [7:0] raddr);
  always @(raddr) begin
    callr: b.Read(raddr);
  end
endmodule
module top(input logic [7:0] x);
  bus_if u();
  cpu c(.b(u), .raddr(x));
endmodule
