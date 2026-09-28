// § parenMethodCallPathSpan207: parenthesized interface function calls in a module process and a continuous assignment, and a parenthesized plain call and package call (controls)
package pk; function automatic int pf(int a); return a; endfunction endpackage
interface bus_if(input logic clk);
  int v;
  function automatic int get(int k = 0); return v + k; endfunction
endinterface
module top(input logic clk, output int o, output int q, output int r);
  bus_if bi(clk);
  function automatic int lf(int a); return a; endfunction
  always_ff @(posedge clk) o <= (bi.get(1)) + ((bi.get(2)));
  assign q = (lf(1)) + (pk::pf(2));
  always_comb r = (bi.get(.k(3)));
endmodule
