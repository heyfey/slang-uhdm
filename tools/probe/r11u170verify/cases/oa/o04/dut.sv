// § elabOvArrFoldSharesDefParamTs163
module dec #(parameter int N = 2, parameter logic [7:0] M [N-1:0] = '{8'h0, 8'h0})
  (input logic [7:0] a, output logic [N-1:0] m);
  for (genvar i = 0; i < N; i++) assign m[i] = a ==? M[i];
endmodule
module top (input logic [7:0] a, output logic [1:0] m [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    dec #(.N(2), .M({{4'bx, 4'b1000}, {4'bx, 4'b0100}})) u(.a(a), .m(m[g]));
  end
endmodule
