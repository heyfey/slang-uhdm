// § defNetVarNoSlot130v
// case v04: var with an anonymous enum without a base, in an interface instantiated twice
interface ifc;
  var enum {P, Q} y;
endinterface
module top(output int o1, output int o2);
  ifc a();
  ifc b();
  assign o1 = a.y;
  assign o2 = b.y;
endmodule
