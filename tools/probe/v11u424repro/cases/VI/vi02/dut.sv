// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a);
endinterface
module top; bit c; logic [1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u(c, x[i]);
  end
endmodule
