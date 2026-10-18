// § ifacePrgOrderedConnMaterializes404v
interface ifc(input logic c); logic d; endinterface
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  sub s1(i, w);
  ifc u(w);
  assign y = w;
endmodule
