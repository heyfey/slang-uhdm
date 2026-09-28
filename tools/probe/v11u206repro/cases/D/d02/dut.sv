// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D;
    static function K::q_t make();
      K::q_t r = new;
      return r;
    endfunction
  endclass
  class E;
    virtual function K::q_t get();
      return null;
    endfunction
  endclass
  class F extends E;
    virtual function K::q_t get();
      return null;
    endfunction
  endclass
endpackage
module d02; endmodule
