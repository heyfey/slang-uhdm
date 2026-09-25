// § typeParamStructAtKeyword146
module sub #(parameter type T = struct packed { logic [3:0] a; }) (input T i, output T o);
  assign o = i;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub #(.T(logic [7:0])) u(.i(i), .o(o));
endmodule
