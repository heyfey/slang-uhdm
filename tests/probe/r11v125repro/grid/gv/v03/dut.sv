// § genvarParamFile125
module sub #(parameter int N = 2) (input logic [N-1:0] a, output logic [N-1:0] o);
  for (genvar k = 0; k < N; k++)
    assign o[k] = ~a[k];
endmodule
module top(input logic [5:0] a, output logic [5:0] o);
  sub #(2) u0(.a(a[1:0]), .o(o[1:0]));
  sub #(4) u1(.a(a[5:2]), .o(o[5:2]));
endmodule
