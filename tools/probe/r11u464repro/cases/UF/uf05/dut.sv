// § unitImpTfNameDedup464 (an out-of-body class method in the home package)
package p;
  class C;
    extern function int m(int x);
  endclass
  function int C::m(int x); return x; endfunction
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  import p::*;
  function automatic int g(int x); return f(x); endfunction
endpackage
import p::*;
import q::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
