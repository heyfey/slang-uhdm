// § portViewParamDefName130
// case p02: an interface array element connected to a plain interface port
interface ifc #(parameter int W = 2);
  logic [W-1:0] d;
endinterface
module sub(ifc b, output logic [2:0] o);
  assign o = b.d;
endmodule
module top(output logic [2:0] o);
  ifc #(.W(3)) i[2]();
  sub u(.b(i[1]), .o(o));
endmodule
