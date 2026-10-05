// § callArgCopyEvalCtxAbstain246v
module sub #(parameter int N = 2) (output logic [7:0] o);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign o = L[0];
endmodule
module top(output logic [7:0] o);
  sub #(.N(3)) u(.o(o));
endmodule
