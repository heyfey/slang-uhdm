// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb case (v[0]) 1'b0: v[fn(1)] = 1'b1; default: v[fn(2)] = 1'b0; endcase
  end
endmodule
