// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
    typedef C #(int) r_t;
  endclass
  class D;
    function K::q_t f();
      K::r_t x;
      return null;
    endfunction
    function K::r_t g();
      return null;
    endfunction
  endclass
endpackage
module d12;
  initial begin
    p::D d = new;
    void'(d.f());
  end
endmodule
