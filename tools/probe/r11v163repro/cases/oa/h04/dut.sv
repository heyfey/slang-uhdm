// § elabOvArrFoldSharesDefParamTs163
module dec #(parameter int W = 8, parameter int N = 2, parameter logic [W-1:0] M [N-1:0] = '{'0, '0})
  (input logic [W-1:0] a, output logic [N-1:0] m);
  for (genvar i = 0; i < N; i++) assign m[i] = a ==? M[i];
endmodule
module top(input logic [3:0] a, output logic [1:0] m);
  dec #(.W(4), .N(2), .M({4'bxx01, 4'bxx10})) u(.a(a), .m(m));
endmodule
