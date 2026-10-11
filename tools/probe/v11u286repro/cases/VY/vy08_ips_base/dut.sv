// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v[fn(1) -: 2] = 2'b01;
  end
endmodule
