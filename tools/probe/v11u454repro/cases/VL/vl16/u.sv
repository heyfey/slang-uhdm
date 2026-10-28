// § pkgLateTsTransitiveImport454
package u;
  class C;
    extern function void f(ref int addr[]);
  endclass
  function void C::f(ref int addr[]);
    foreach (addr[i]) addr[i] = 0;
  endfunction
endpackage
