// § elabOvArrFoldSharesDefParamTs163
module dec #(parameter logic [7:0] M [1:0] = '{8'h0, 8'h0})
  (input logic [7:0] a, output logic [1:0] m);
  for (genvar i = 0; i < 2; i++) assign m[i] = a == M[i];
endmodule
module top(input logic [7:0] a, output logic [1:0] m);
  dec #(.M({8'h1, 8'h2})) u(.a(a), .m(m));
endmodule
