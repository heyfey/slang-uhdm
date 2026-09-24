// § implicitNetMintNoFile131
interface ifc (input logic clk, input logic a, input logic b);
  property p1(req, ack);
    @(posedge clk) req |-> ack;
  endproperty
  assert property (p1(a, b));
endinterface
module top (input logic clk, input logic a, input logic b);
  ifc u(.clk(clk), .a(a), .b(b));
endmodule
