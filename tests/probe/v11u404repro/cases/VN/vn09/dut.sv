// § ifacePrgOrderedConnMaterializes404v
interface ifc(input logic c); logic d; endinterface
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  ifc u(w);
  sub s1(w, y);
  assign w = i;
endmodule
