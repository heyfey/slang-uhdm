// § callArgParamCopyOwnTs246
module sub #(parameter logic [3:0] N = 4'd3, parameter shortint S = 16'sd2) (output logic [N-1:0][7:0] o, output logic [S-1:0][7:0] p);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i);
    return r;
  endfunction
  function automatic bit [S-1:0][7:0] g(byte n);
    bit [S-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i * 2);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  localparam bit [S-1:0][7:0] M = g(S);
  assign o = L;
  assign p = M;
endmodule
module top(output logic [4:0][7:0] o, output logic [2:0][7:0] p);
  sub #(.N(4'd5), .S(16'sd3)) u(.o(o), .p(p));
endmodule
