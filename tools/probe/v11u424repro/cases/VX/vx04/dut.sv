// § ifcProcCallArgNoTs424
package p;
  function automatic int f(int v); return v + 1; endfunction
endpackage
interface ifc(input bit clk);
  int x;
  int z;
  assign z = p::f(x);
  always_comb begin int t; t = p::f(z); end
endinterface
module top; bit c; ifc d1(.clk(c)); ifc d2(.clk(c)); endmodule
