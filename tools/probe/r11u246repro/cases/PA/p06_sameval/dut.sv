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
  assign o = L;
endmodule
module top(output logic [3:0][15:0] o);
  sub #(.N(4)) u(.o(o));
endmodule
