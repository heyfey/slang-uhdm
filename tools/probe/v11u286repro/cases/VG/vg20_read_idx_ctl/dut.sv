// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v;
  int a [4];
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v[a[fn(1)]] = 1'b1;
  end
endmodule
