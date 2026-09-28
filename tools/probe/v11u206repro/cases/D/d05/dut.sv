// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D #(type U = int);
    function K::q_t f();
      return null;
    endfunction
  endclass
  typedef D #(logic) d_t;
endpackage
module d05; endmodule
