// § defGenConnVarSelIdxPart440
`define MIN(a,b) ((a)<(b)?(a):(b))
module sub #(parameter w = 4) (input [w-1:0] i, output [w-1:0] o); assign o = i; endmodule
module top #(parameter n = 2, parameter w = 2) (input [7:0] a [1:0], input s, output [3:0] y [1:0]);
  for (genvar k = 0; k < n; k++) begin : g
    sub #(.w(4)) u (.i(a[s][k*2+:`MIN(k+1,n)*w]), .o(y[k]));
  end
endmodule
