// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class A;
    class K;
      typedef C #(shortint) q_t;
    endclass
  endclass
  class B;
    function A::K::q_t f();
      return null;
    endfunction
    static function A::K::q_t g(); return null; endfunction
  endclass
endpackage
module r08; endmodule
