// § unitImpTfNameDedup464 (a $unit function beside the imports)
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  import p::*;
  function automatic int g(int x); return f(x); endfunction
endpackage
import p::*;
import q::*;
function automatic int u(int x); return x; endfunction
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
