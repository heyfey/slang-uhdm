// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
endpackage
interface ifc (input logic clk);
  import up::*;
  int w;
  property pp; @(posedge clk) (w inside {A, B}) |-> ##1 w != 0; endproperty
  a1: assert property (pp);
  function automatic bit h(); return w inside {A, B}; endfunction
endinterface
module top (input logic clk);
  ifc i(.clk(clk));
endmodule
