// § rootLvalueSpanAtRoot184: $root targets in a continuous assignment, a generate scope, a task and a class method; a $root read in an lvalue index (control)
module top; wire [3:0] w; logic [3:0] v; logic [1:0] i; sub u(); endmodule
module sub #(parameter bit P = 1);
  logic [3:0] arr;
  assign $root.top.w = 4'd6;
  if (P) begin : g
    initial $root.top.v = 4'd7;
  end
  task automatic t();
    $root.top.v[1] = 1'b1;
  endtask
  class C;
    function void f();
      $root.top.v = 4'd8;
    endfunction
  endclass
  initial arr[$root.top.i] = 1'b0;
endmodule
