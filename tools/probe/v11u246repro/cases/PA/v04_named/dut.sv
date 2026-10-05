// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n, int base = 0);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i + base);
    return r;
  endfunction
  localparam bit [N-1:0][15:0] L = f(.n(N));
  localparam bit [N-1:0][15:0] M = f(N, );
  assign o = L ^ M;
endmodule
module top(output logic [2:0][15:0] o);
  sub #(.N(3)) u(.o(o));
endmodule
