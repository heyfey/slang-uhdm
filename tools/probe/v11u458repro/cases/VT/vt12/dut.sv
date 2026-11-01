// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern function void f();
  endclass
  function void C::f();
    byte a, b, c;
  endfunction
endpackage
package ap;
  import p::*;
  int k;
endpackage
package bp;
  import ap::*;
  int j;
endpackage
module top;
  import p::*;
  import bp::*;
endmodule
