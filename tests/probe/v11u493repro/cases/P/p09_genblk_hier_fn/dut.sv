// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  typedef int t32;
  if (1) begin : gb
    int x;
    assign x = a;
  end
  function int f();
    return int'(t32'(gb.x));
  endfunction
  assign v = f();
endmodule
