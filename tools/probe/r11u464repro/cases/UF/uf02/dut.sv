// § unitImpTfNameDedup464 (two packages with an own function of one name)
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  function automatic int f(int x); return x + 2; endfunction
  function automatic int h(int x); return x + 3; endfunction
endpackage
import p::*;
import q::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
