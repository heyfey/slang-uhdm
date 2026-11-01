// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern   function void f();
  endclass
  function void C::f();
    int a, b;
  endfunction
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top;
  import p::*;
  import ap::*;
endmodule
