// § rootLvalueSpanAtRoot184: a $root target in a function body
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub;
  function automatic void setv(logic [7:0] a);
    $root.top.v = a;
  endfunction
  initial setv(8'd9);
endmodule
