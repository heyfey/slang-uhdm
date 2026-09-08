// v214 arm 5 — MODULE AND INTERFACE CONTEXTS, and NON-CLONE BODIES.  The same
// package parameters read from: a module body, an interface body, a package
// FREE function, a package-scope variable initialiser, and a param_assign
// initialiser.  None of these is a def class-method clone listing; none may
// move.
package pv5;
  parameter int ma5 = 6;
  parameter mb5 = ma5;
  parameter mc5 = ma5 + 2;
  int pkgvar5 = mb5;
  function automatic int free5();
    return ma5 + mb5 + mc5;
  endfunction
  class C5;
    extern function int c_rd5();
  endclass
  function int C5::c_rd5();
    return ma5 + mb5;
  endfunction
endpackage
interface if5;
  import pv5::*;
  logic [mb5-1:0] bus;
  function automatic int if_rd5(); return mb5 + mc5; endfunction
endinterface
module topv5;
  import pv5::*;
  if5 u_if();
  pv5::C5 c = new();
  int x, y, z;
  initial begin
    x = ma5 + mb5;
    y = pv5::free5();
    z = c.c_rd5();
  end
endmodule
