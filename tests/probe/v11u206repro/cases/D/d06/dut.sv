// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D;
    extern function K::q_t f(int a);
    extern function
      K::q_t g();
  endclass
  function K::q_t D::f(int a);
    return null;
  endfunction
  function
     K::q_t D::g();
    return null;
  endfunction
endpackage
module d06; endmodule
