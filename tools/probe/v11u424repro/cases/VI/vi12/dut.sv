// § ifcConcAssertListed424
interface ifc(input bit clk);
  logic a;
  assert property (@(posedge clk) a);
endinterface
module top; bit c; endmodule
