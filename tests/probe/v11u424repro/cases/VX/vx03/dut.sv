// § ifcProcCallArgNoTs424
package p;
  function automatic bit chk(int v); return v > 0; endfunction
endpackage
interface ifc(input bit clk);
  int x;
  assert property (@(posedge clk) p::chk(x)) else $error("bad %0d", x);
endinterface
module top; bit c; ifc d(.clk(c)); endmodule
