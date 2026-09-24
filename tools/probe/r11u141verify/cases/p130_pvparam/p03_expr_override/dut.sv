// § portViewParamDefName130
// case p03: override written as an expression, two parameters, one left at its default
interface ifc #(parameter int W = 2, parameter int D = 1);
  logic [W-1:0] d;
endinterface
module sub(ifc b, output logic [5:0] o);
  assign o = b.d;
endmodule
module top(output logic [5:0] o);
  ifc #(.W(2*3)) i();
  sub u(.b(i), .o(o));
endmodule
