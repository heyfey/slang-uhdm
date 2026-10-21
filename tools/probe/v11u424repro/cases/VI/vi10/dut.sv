// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  if (1) begin : g
    assert property (@(posedge clk) a);
  end
  assert property (@(posedge clk) !a);
endinterface
module top; bit c; logic x; ifc u(c, x); endmodule
