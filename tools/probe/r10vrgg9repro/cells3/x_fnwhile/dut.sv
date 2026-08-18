module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  function automatic int fw(int n); int s=0; while (n>0) begin s+=n; n--; end return s; endfunction

  assign arr[0] = (P) ? fw(4) : 7;
endmodule
module top;
  m u_a();
endmodule
