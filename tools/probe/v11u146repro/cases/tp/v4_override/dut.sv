// § typeParamStructAtKeyword146
module m #(parameter type T = struct packed { logic a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
module top(input [1:0] i, output [1:0] o, input [3:0] j, output [3:0] p);
  m u(.i(i), .o(o));
  m #(.T(logic [3:0])) w(.i(j), .o(p));
endmodule
