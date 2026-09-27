// § rootLvalueSpanAtRoot184: a $root target inside an lvalue concatenation, in a function, in a generate scope, and a macro-born select target
module top; logic [3:0] v; logic [3:0] w; logic clk; sub u(); endmodule
`define RTS(k) $root.top.w[k]
module sub #(parameter bit P = 1);
  logic [1:0] y;
  function automatic void setv(logic [3:0] a);
    $root.top.v = a;
  endfunction
  initial begin
    {$root.top.v, y} = 6'h15;
    setv(4'd9);
    `RTS(2) = 1'b1;
  end
  if (P) begin : g
    always @(posedge $root.top.clk) $root.top.w <= $root.top.v;
  end
endmodule
