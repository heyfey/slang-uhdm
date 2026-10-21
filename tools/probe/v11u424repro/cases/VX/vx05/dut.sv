// § ifcProcCallArgNoTs424
package p;
  function automatic int f(int v); return v + 1; endfunction
endpackage
interface ifc(input bit clk);
  int x;
  modport mp(input x);
  always @(posedge clk) x <= p::f(x);
endinterface
module sub(ifc.mp m); endmodule
module top; bit c; ifc d(.clk(c)); sub s(d); endmodule
