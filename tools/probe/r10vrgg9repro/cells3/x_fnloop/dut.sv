module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  function automatic int fl(int n); int s=0; for (int i=0;i<n;i++) s+=i; return s; endfunction

  assign arr[0] = (P) ? fl(4) : 7;
endmodule
module top;
  m u_a();
endmodule
