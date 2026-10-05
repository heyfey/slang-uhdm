// § callArgCopyReduceOpModel248
module sub #(parameter int N = 2) (output logic [N-1:0][7:0] o, output logic [7:0] q, input logic [7:0] a);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i + 1);
    return r;
  endfunction
  function automatic bit [7:0] g(bit [7:0] v);
    return v + 8'd1;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign o = L;
  logic [7:0] z;
  always_comb z = o[0][L[0]:0];
  assign q = z;
endmodule
module top(output logic [2:0][7:0] o, output logic [7:0] q, input logic [7:0] a);
  sub #(.N(3)) u(.o(o), .q(q), .a(a));
endmodule
