// § tpCastOverrideKeepsDefault407
interface ifc #(parameter type T = logic [7:0], parameter T D = T'(5));
  T v;
  assign v = D;
endinterface
module top(output logic [3:0] o);
  ifc #(.T(logic [3:0])) i();
  assign o = i.v;
endmodule
