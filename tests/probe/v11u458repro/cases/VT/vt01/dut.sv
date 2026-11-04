// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    function void f();
      int a, b;
    endfunction
  endclass
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top;
  import p::*;
  import ap::*;
endmodule
