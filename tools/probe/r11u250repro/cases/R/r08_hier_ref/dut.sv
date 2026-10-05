// § callArgCopyElabNearestOp248v (decode only, no law of r11u250: a hierarchical reference u.L[1] from the parent)
module sub #(parameter int N = 2) (output logic [N-1:0][7:0] o);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i + 1);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign o = L;
endmodule
module top(output logic [2:0][7:0] o, output logic [7:0] q);
  sub #(.N(3)) u(.o(o));
  assign q = u.L[1] + 8'd1;
endmodule
