// § ifcProcCallArgNoTs424
package p;
  function automatic int f(int v, logic [3:0] w); return v + w; endfunction
endpackage
interface ifc(input bit clk);
  int x;
  logic [3:0] y;
  initial x = p::f(1, y);
  always @(posedge clk) x <= p::f(x + 1, 4'h3);
endinterface
module top;
  bit c;
  ifc d(.clk(c));
endmodule
