// § typeParamStructAtKeyword146
interface ifc #(parameter type T = struct packed { logic [3:0] a; }); T v; endinterface
module top(output logic [3:0] o);
  ifc u();
  assign o = u.v.a;
endmodule
