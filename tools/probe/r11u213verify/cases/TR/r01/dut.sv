// § classScopeTdRetBuildsOwner206 (a typedef of a typedef in the owner; the owner sorts after)
package p;
  class C #(type T = int); T v; endclass
  class K;
    typedef C #(byte) q_t;
    typedef q_t q2_t;
  endclass
  class B;
    function K::q2_t f(); return null; endfunction
    function K::q_t g(); return null; endfunction
  endclass
endpackage
module r01; endmodule
