// § classScopeTdRetBuildsOwner206 (a typedef inherited two levels up, returned in the grandchild)
package p;
  class C #(type T = int); T v; endclass
  class A; typedef C #(shortint) t_t; endclass
  class M extends A; int k; endclass
  class Z extends M;
    function t_t f(); return null; endfunction
    function A::t_t g(); return null; endfunction
  endclass
endpackage
module r02; endmodule
