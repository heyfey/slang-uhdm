// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i);
    return r;
  endfunction
  if (N > 2) begin : g
    localparam bit [N-1:0][15:0] L = f(N);
    assign o = L;
  end
endmodule
module top(output logic [24:0][15:0] o);
  sub #(.N(25)) u(.o(o));
endmodule
