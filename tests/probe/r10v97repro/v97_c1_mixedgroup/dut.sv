// v97_c1 — THE OVER-FIRE PROBE.  A REAL cross-class group one of whose members
// is a PARAMETERIZED class with two live specializations whose owner key sorts
// AFTER the base's.  Pristine aliases BOTH specialization copies to the base;
// the patch drops the alias from the second.  Golden has ONE zzz copy, aliased.
package p97c1;
  class tgt97c1;
    int q;
  endclass
  class aaa97c1;                          // work-key sorts FIRST
    typedef tgt97c1 nn97c1;
    nn97c1 h_a;
    function nn97c1 get_a(); return h_a; endfunction
  endclass
  class zzz97c1 #(type T = int);          // sorts LAST -> never the base
    typedef tgt97c1 nn97c1;
    nn97c1 h_z;
    T v;
    function void use_z(nn97c1 p); h_z = p; endfunction
  endclass
  class si97c1 extends zzz97c1 #(int);
    function void f(nn97c1 p); h_z = p; endfunction
  endclass
  class sb97c1 extends zzz97c1 #(byte);
    function void f(nn97c1 p); h_z = p; endfunction
  endclass
endpackage
module top97c1;
endmodule
