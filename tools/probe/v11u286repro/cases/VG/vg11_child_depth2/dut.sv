// § genProcLvIdxCallSpan286
module sub;
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v[fn(3)] = 1'b1;
  end
endmodule
module mid;
  sub s();
endmodule
module top;
  mid m();
endmodule
