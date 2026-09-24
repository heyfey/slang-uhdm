// § tsHierPathElemNoName134
interface ifc #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module sub(ifc i, output logic [3:0] o);
  logic [i.W-1:0] x;
  assign x = i.d;
  assign o = x;
endmodule
module top(output logic [3:0] o);
  ifc #(4) b();
  sub s(.i(b), .o(o));
endmodule
