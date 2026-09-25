// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed { logic [3:0] a; }) (input logic [3:0] i, output logic [3:0] o);
  T v;
  assign v.a = i;
  assign o = v.a;
endmodule
