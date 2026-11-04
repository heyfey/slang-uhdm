// § typeParamStructAtKeyword146
module m #(parameter type T = struct packed signed { logic [3:0] a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
module top(input [4:0] i, output [4:0] o); m u(.i(i), .o(o)); endmodule
