// § classScopeTdRetBuildsOwner206
package z_pkg;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
endpackage
package a_pkg;
  class D;
    function z_pkg::K::q_t f();
      return null;
    endfunction
  endclass
endpackage
module d11; endmodule
