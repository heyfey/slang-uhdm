// § refFullNameThroughNamedExpr175
module top;
  localparam int W = 3;
  int g;
  function automatic int f(int a = W, int b = g); return a + b; endfunction
  task automatic t(int c = W + 1); endtask
  int r; initial begin r = f(); t(); end
endmodule
