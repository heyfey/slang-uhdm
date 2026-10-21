// § ifcConcAssertListed424
interface ifc(input bit clk);
  logic a, b;
  assert property (@(posedge clk) a |-> b);
  modport mp(input a, b);
endinterface
module sub(ifc.mp p); endmodule
module top; bit c; ifc u1(c); ifc u2(c); sub s1(u1); sub s2(u2); endmodule
