// § typeParamStructAtKeyword146
module m #(parameter type T = union packed { logic [3:0] a; logic [3:0] b; }) (input T i, output T o);
  assign o = i;
endmodule
module top(input [3:0] i, output [3:0] o); m u(.i(i), .o(o)); endmodule
