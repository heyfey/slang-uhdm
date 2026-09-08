// ARM D — the MODULE importer control for arm C: a module wildcard-import
// builds no package clone at all, so the home package's two listings are the
// whole population.
package p213d;
  class c213d #(type T213 = int);
    extern function void fd213(T213 x213);
  endclass
  function void c213d::fd213(T213 x213);
    T213 locd213;
    locd213 = x213;
  endfunction
endpackage
module top213d;
  import p213d::*;
  initial begin end
endmodule
