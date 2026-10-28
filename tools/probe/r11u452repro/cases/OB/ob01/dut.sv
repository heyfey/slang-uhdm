// § pkgGroupOwnOobDef452
package p;
  function int pf(); return 1; endfunction
endpackage
package q;
  import p::*;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import p::*;
  import q::*;
  class S;
    int y;
    function void plain(); endfunction
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule
