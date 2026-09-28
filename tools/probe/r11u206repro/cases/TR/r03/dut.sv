// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D;
    extern function K::q_t lookup(string s);
  endclass
  function K::q_t D::lookup(string s);
    return null;
  endfunction
endpackage
module r03; endmodule
