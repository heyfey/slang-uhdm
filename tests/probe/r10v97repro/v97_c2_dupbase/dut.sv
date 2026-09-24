// v97_c2 — the MIRROR of c1: the parameterized member sorts FIRST, so the
// duplicate set IS the group base and un-aliasing the extra copy is golden.
package p97c2;
  class tgt97c2;
    int q;
  endclass
  class aaa97c2 #(type T = int);          // sorts FIRST -> the base
    typedef tgt97c2 nn97c2;
    nn97c2 h_a;
    T v;
  endclass
  class zzz97c2;                          // sorts LAST -> the clone
    typedef tgt97c2 nn97c2;
    nn97c2 h_z;
  endclass
  class si97c2 extends aaa97c2 #(int);
    function void f(nn97c2 p); h_a = p; endfunction
  endclass
  class sb97c2 extends aaa97c2 #(byte);
    function void f(nn97c2 p); h_a = p; endfunction
  endclass
endpackage
module top97c2;
endmodule
