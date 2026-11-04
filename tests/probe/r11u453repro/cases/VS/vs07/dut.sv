// § vsTrailRangeColonJoin453
module top;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:2] = 1;
  endfunction
  logic [3:0][7:0] q;
  int k;
  always_comb q[k][k+:2] = 1;
endmodule
