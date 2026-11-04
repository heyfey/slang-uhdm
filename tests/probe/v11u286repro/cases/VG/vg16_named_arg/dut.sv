// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v[fn(.a(2))] = 1'b1;
  end
endmodule
