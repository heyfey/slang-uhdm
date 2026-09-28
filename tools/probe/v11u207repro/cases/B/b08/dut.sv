// § namedUnlinkedWrittenOrder207: an interface function called by name before its declaration and a module function called by name from a two-level generate, both views
interface bus_if(input logic clk);
  int v;
  function int first(int x); return later(.c(x), .a(1)); endfunction
  function int later(int a, int b = 2, int c = 3); return a + b + c; endfunction
endinterface
module top(input logic clk, output int o [2][2]);
  bus_if b(clk);
  function automatic int h(int a, int b = 1, int c = 2); return a + b + c; endfunction
  for (genvar i = 0; i < 2; i++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      always_ff @(posedge clk) o[i][j] <= h(.c(j), .a(i)) + b.first(i);
    end
  end
endmodule
