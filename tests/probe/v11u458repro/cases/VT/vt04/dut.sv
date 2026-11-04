// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern function int f();
  endclass
  function int C::f();
    logic [3:0] a;
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
