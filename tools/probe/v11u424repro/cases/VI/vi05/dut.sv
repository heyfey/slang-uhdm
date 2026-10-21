// § ifcConcAssertListed424
interface ifc #(parameter W = 1) (input bit clk);
  logic [W-1:0] d;
  assert property (@(posedge clk) d != 0);
endinterface
module top; bit c;
  ifc #(2) u1(c);
  ifc #(4) u2(c);
endmodule
