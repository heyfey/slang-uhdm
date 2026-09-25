// § elabOvArrFoldSharesDefParamTs163
module dec #(parameter int N = 2, parameter logic [7:0] M [N-1:0] = '{8'h0, 8'h0})
  (input logic [7:0] a, output logic [N-1:0] m);
  for (genvar i = 0; i < N; i++) assign m[i] = a == M[i];
endmodule
module top(input logic [7:0] a, output logic [2:0] m, output logic [1:0] n);
  dec #(.N(3), .M({8'h1, 8'h2, 8'h3})) u(.a(a), .m(m));
  dec #(.N(2), .M({8'h4, 8'h5})) v(.a(a), .m(n));
endmodule
