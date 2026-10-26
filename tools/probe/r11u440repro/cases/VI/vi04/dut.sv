// § defGenConnVarSelIdxPart440
module sub #(parameter w = 4) (input [w-1:0] i, output [w-1:0] o); assign o = i; endmodule
module top (input [7:0] a [1:0], input s, output [3:0] y);
  sub #(.w(4)) u (.i(a[s][0+:4]), .o(y));
endmodule
