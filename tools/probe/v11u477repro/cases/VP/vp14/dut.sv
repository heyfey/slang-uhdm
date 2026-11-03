// § parenCallWrittenArgs477
interface ifc(input logic clk);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  int w;
  initial w = (f(2));
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
