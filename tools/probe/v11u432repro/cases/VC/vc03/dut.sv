// § clsParamCallArgPkgSel432
package pk;
  function automatic int f(int a); return a + 1; endfunction
endpackage
import pk::*;
function automatic int g(int a); return a; endfunction
class C;
  localparam M = f(3);
  localparam K = g(f(2));
endclass
module test;
endmodule
