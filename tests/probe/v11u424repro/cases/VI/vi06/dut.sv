// § ifcConcAssertListed424
interface ifc(input bit clk);
  logic a, b;
  assert property (@(posedge clk) a |-> b);
  modport mp(input a, b);
endinterface
module sub(ifc.mp p); endmodule
module top; bit c; ifc u(c); sub s(u); endmodule
