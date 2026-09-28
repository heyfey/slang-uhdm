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
  import z_pkg::*;
  class D;
    function K::q_t f();
      return null;
    endfunction
  endclass
endpackage
module d10; endmodule
