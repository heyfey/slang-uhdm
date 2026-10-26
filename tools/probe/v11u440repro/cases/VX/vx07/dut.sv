// § defGenConnVarSelIdxPart440
module sub2 (input [3:0] i, output [3:0] o); assign o = i; endmodule
module mid #(parameter n = 2) (input [3:0] a [1:0], input s, output [7:0] y [1:0]);
  for (genvar k = 0; k < n; k++) begin : g
    sub2 u (.i(a[k]), .o(y[s][4+:4]));
  end
endmodule
module top; endmodule
