// § implicitNetMintNoFile131
module top (input logic clk, input logic a, input logic b);
  if (1) begin : g
    property p1(req, ack);
      @(posedge clk) req |-> ack;
    endproperty
    assert property (p1(a, b));
  end
endmodule
