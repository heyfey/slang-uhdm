// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i);
    return r;
  endfunction
  function automatic bit [N-1:0][15:0] g(bit [N-1:0][15:0] s);
    return s;
  endfunction
  function automatic int h(bit [N-1:0][15:0] s);
    return s[0];
  endfunction
  localparam bit [N-1:0][15:0] L = f(N);
  localparam bit [N-1:0][15:0] M = g(L);
  localparam int K = h(M);
  assign o = L;
endmodule
module top(output logic [24:0][15:0] o);
  sub #(.N(25)) u(.o(o));
endmodule
