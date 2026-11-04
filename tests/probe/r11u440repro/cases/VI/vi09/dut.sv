// § defGenConnVarSelIdxPart440
`define MIN(a,b) ((a)<(b)?(a):(b))
module sub #(parameter w = 4) (input [w-1:0] i, output [w-1:0] o); assign o = i; endmodule
module mid #(parameter w) (input [7:0] a [1:0], input s, output [3:0] y [1:0]);
  localparam n = 2;
  for (genvar k = 0; k < n; k++) begin : g
    if (k > 0) begin : h
      sub #(.w(4)) u (.i(a[s][0+:`MIN(k+1,n)*w]), .o(y[k]));
    end
  end
endmodule
module mid__abstract(); if (0) begin : abstract mid not_used(); end endmodule
module top; endmodule
