module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  function automatic int fr(int n); if (n<=0) return 1; return n*fr(n-1); endfunction

  assign arr[0] = (P) ? fr(3) : 7;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
