// § portViewParamDefName130
// case p01: interface with a string parameter and an int parameter, overridden, reached through a plain interface port
interface ifc #(parameter int W = 2, parameter string S = "ab");
  logic [W-1:0] d;
endinterface
module sub(ifc b, output logic [3:0] o);
  assign o = b.d;
endmodule
module top(output logic [3:0] o);
  ifc #(.W(4), .S("cd")) i();
  sub u(.b(i), .o(o));
endmodule
