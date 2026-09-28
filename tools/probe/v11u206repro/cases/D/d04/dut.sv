// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
    function q_t mine();
      return null;
    endfunction
  endclass
  class A;
    function K::q_t f();
      return null;
    endfunction
  endclass
  class Z;
    function K::q_t g();
      return null;
    endfunction
  endclass
endpackage
module d04; endmodule
