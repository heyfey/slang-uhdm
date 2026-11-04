// § unitImpTfNameDedup464 (a three-package chain imported in home-first order)
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  import p::*;
  function automatic int g(int x); return f(x); endfunction
endpackage
package r;
  import q::*;
  import p::*;
  function automatic int h(int x); return g(x) + f(x); endfunction
endpackage
import p::*;
import q::*;
import r::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
