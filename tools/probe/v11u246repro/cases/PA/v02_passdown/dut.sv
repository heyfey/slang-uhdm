// § callArgParamCopyOwnTs246
module leaf #(parameter int unsigned N = 2) (output logic [N-1:0][7:0] o);
  function automatic bit [N-1:0][7:0] f(int unsigned n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i + 1);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign o = L;
endmodule
module mid #(parameter int unsigned N = 3) (output logic [N-1:0][7:0] o);
  leaf #(.N(N)) l(.o(o));
endmodule
module top(output logic [4:0][7:0] o);
  mid #(.N(5)) m(.o(o));
endmodule
