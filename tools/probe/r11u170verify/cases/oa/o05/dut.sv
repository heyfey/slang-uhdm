// § elabOvArrFoldSharesDefParamTs163
module dec #(parameter int N = 3, parameter logic [5:0] M [N-1:0] = '{6'h0, 6'h0, 6'h0})
  (input logic [5:0] a, output logic [N-1:0] m);
  for (genvar i = 0; i < N; i++) assign m[i] = a ==? M[i];
endmodule
module top (input logic [5:0] a, output logic [2:0] m, output logic [2:0] n);
  dec #(.M({{3'bx, 3'b001}, {3'bx, 3'b010}, {3'b1x0, 3'bxxx}})) u(.a(a), .m(m));
  dec v(.a(a), .m(n));
endmodule
