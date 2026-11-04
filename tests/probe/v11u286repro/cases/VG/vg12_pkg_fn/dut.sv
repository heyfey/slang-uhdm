// § genProcLvIdxCallSpan286
package pk;
  function automatic int fn(int a); return a; endfunction
endpackage
module top;
  logic [3:0] v;
  if (1) begin : gi
    always_comb v[pk::fn(2)] = 1'b1;
  end
endmodule
