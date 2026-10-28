// § oobInheritedCallBindsOwnPkgClone455
// a module (synthesizable) that also imports q; downstream lane control
package p;
  function automatic int f(int a); return a + 1; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
  function automatic int pf(int a); return f(a); endfunction
endpackage
module top(input logic [7:0] a, output logic [7:0] y);
  import q::*;
  assign y = pf(a);
endmodule
