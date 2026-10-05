// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4, parameter int W = 3) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n, int w);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i + w);
    return r;
  endfunction
  localparam bit [N-1:0][15:0] L = f(N, W);
  assign o = L;
endmodule
module top(output logic [24:0][15:0] o);
  sub #(.N(25), .W(2)) u(.o(o));
endmodule
