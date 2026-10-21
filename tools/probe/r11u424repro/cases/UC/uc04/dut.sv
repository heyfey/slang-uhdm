// § ifcProcCallArgNoTs424 (control: a continuous assign and a function body in an interface)
package p;
  function automatic int f(int v); return v + 1; endfunction
endpackage
interface ifc(input bit clk);
  int x, z;
  assign z = p::f(x);
  function automatic int h(int v); return p::f(v); endfunction
endinterface
module top;
  bit c;
  ifc d(.clk(c));
endmodule
