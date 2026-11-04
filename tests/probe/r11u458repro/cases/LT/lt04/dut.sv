// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern   function int g();
  endclass
  function int C::g();
    int a;
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
