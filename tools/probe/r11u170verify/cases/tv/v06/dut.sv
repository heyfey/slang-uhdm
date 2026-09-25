// § defNetTypeParamPackedVec160
module sub #(parameter type T = logic [3:0], parameter int N = 2) (input logic [7:0] i, output logic [15:0] o);
  wire T [N-1:0] w;
  assign w = i;
  assign o = 16'(w);
endmodule
module top (input logic [7:0] a, output logic [15:0] o);
  sub u(.i(a), .o(o));
endmodule
