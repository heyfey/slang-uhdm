// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v;
  if (1) begin : gi
    function automatic int gf(int a); return a; endfunction
    always_comb v[gf(1)] = 1'b1;
  end
endmodule
