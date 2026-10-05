// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4, parameter bit EN = 1) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i);
    return r;
  endfunction
  if (EN) begin : g_on
    localparam bit [N-1:0][15:0] L = f(N);
    assign o = L;
  end else begin : g_off
    assign o = '0;
  end
endmodule
module top(output logic [5:0][15:0] o);
  sub #(.N(6)) u(.o(o));
endmodule
