// § unitImpTfNameDedup464 (two unrelated packages with a function of one name)
package p1;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package p2;
  function automatic int f(int x); return x + 2; endfunction
  function automatic int g(int x); return x + 3; endfunction
endpackage
import p1::*;
import p2::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
