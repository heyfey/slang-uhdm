// § pkgLateTsTransitiveImport454
package u;
  class C;
    int q[$];
    function void f();
      foreach (q[k]) q[k] = 0;
    endfunction
    extern function void g(ref int q[$]);
  endclass
  function void C::g(ref int q[$]);
    foreach (q[j]) q[j] = 1;
  endfunction
endpackage
package mid;
  export u::*;
  import u::*;
  int z;
endpackage
module top(output logic [1:0] q);
  import mid::*;
  assign q = 0;
endmodule
