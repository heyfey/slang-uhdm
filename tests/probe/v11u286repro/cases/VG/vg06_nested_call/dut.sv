// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  function automatic int fz(); return 2; endfunction
  if (1) begin : gi
    always_comb begin
      v[fn(fn(1))] = 1'b1;
      v[fz()] = 1'b0;
    end
  end
endmodule
