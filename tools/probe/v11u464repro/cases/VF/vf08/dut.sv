// § unitImpTfNameDedup464 (a $unit function of the imported name)
package p1;
  function automatic int f(int x); return x + 1; endfunction
  function automatic int k(int x); return x + 1; endfunction
endpackage
package p2;
  function automatic int f(int x); return x + 2; endfunction
endpackage
function automatic int f(int x); return x + 9; endfunction
import p1::*;
import p2::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
