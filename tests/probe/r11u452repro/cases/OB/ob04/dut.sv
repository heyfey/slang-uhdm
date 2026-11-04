// § pkgGroupOwnOobDef452
package p;
  function int pf(); return 1; endfunction
endpackage
package q;
  import p::*;
  function int qa(); return 2; endfunction
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
  function int qb(); return 3; endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
  endclass
endpackage
module top;
  import r::*;
endmodule
