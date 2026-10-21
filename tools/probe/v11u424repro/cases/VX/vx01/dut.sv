// § ifcProcCallArgNoTs424
interface ifc(input bit clk);
  int x;
  function automatic int f(int v); return v + 1; endfunction
  always @(posedge clk) x <= f(x);
endinterface
module top; bit c; ifc d(.clk(c)); endmodule
