// § elabOvArrFoldSharesDefParamTs163
interface dec #(parameter int N = 2, parameter logic [7:0] M [N-1:0] = '{8'h0, 8'h0}) ();
  logic [7:0] a; logic [N-1:0] m;
  for (genvar i = 0; i < N; i++) assign m[i] = a ==? M[i];
endinterface
module top;
  dec #(.N(2), .M({{4'bx, 4'b0001}, {4'bx, 4'b0010}})) u();
endmodule
