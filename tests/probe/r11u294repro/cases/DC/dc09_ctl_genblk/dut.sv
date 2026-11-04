// § dottedCallHpSpansInvocation294
// CONTROL: a generate-block function with an argument
module top(output int o);
  if (1) begin : blk
    function int f(int a); return a + 1; endfunction
  end
  assign o = blk.f(3);
endmodule
