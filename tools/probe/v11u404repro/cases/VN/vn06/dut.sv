// § ifacePrgOrderedConnMaterializes404v
interface ifc(input logic c); logic d; endinterface
module top(input i, output y);
  ifc u(w);
  assign w = i;
  assign y = u.d;
endmodule
